###########################################################
###########################################################
# Lambda Function: Image Processor
# Description: Processes images uploaded to S3 by compressing
#              and converting formats. Logs structured data and
#              publishes custom metrics to CloudWatch.
# Documentation: 
# https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
###########################################################
###########################################################



import json
import boto3
import os
import logging
import time
from urllib.parse import unquote_plus
from io import BytesIO
from PIL import Image
import uuid
from datetime import datetime

# Configure structured logging
logger = logging.getLogger() # Get the root logger instance provided by the Lambda runtime
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO')) # Set logging level from environment variable, default to INFO

# AWS clients
s3_client = boto3.client('s3')
cloudwatch = boto3.client('cloudwatch')

# Supported formats
SUPPORTED_FORMATS = ['JPEG', 'PNG', 'WEBP', 'BMP', 'TIFF']
DEFAULT_QUALITY = 85
MAX_DIMENSION = 4096

def lambda_handler(event, context):
    """
    Lambda function to process images uploaded to S3.
    Supports compression and format conversion.
    """
    start_time = time.time() # Record the start time of the Lambda execution
    request_id = context.aws_request_id if context else 'local' # Get the AWS request ID or default to 'local' for testing
    
    try:
        logger.info(f"REQUEST_ID: {request_id} - Received event: {json.dumps(event)}") # Log the incoming event
        
        processed_count = 0 # Initialize a counter for processed images
        
        # Get the S3 event details from each record in the event
        for record in event['Records']: # Iterate through each S3 event record
            bucket = record['s3']['bucket']['name'] # Extract the S3 bucket name
            key = unquote_plus(record['s3']['object']['key']) # Extract and URL-decode the S3 object key
            file_size = record['s3']['object'].get('size', 0) # Get the size of the S3 object, default to 0 if not present
            
            logger.info(f"REQUEST_ID: {request_id} - Processing image: {key} from bucket: {bucket}, image_size: {file_size} bytes") # Log details of the image being processed
            
            # Log a warning if the image file size exceeds 10 MB
            if file_size > 10 * 1024 * 1024: # Check if file size is greater than 10 MB
                logger.warning(f"REQUEST_ID: {request_id} - Large image detected: {key} ({file_size} bytes)") # Log a warning for large images
            
            # Download the image from S3
            download_start = time.time() # Record the start time of the download
            response = s3_client.get_object(Bucket=bucket, Key=key) # Download the object from S3
            image_data = response['Body'].read() # Read the image data from the response body
            download_time = (time.time() - download_start) * 1000 # Calculate download time in milliseconds
            
            logger.info(f"REQUEST_ID: {request_id} - Downloaded in {download_time:.2f}ms") # Log the download time
            
            # Process the image
            process_start = time.time() # Record the start time of image processing
            processed_images = process_image(image_data, key, request_id) # Call the helper function to process the image
            process_time = (time.time() - process_start) * 1000 # Calculate processing time in milliseconds
            
            logger.info(f"REQUEST_ID: {request_id} - processing_time: {process_time:.2f}ms") # Log the image processing time
            
            # Upload processed images to the processed bucket
            processed_bucket = os.environ['PROCESSED_BUCKET'] # Get the name of the processed bucket from environment variables
            
            upload_start = time.time() # Record the start time of the upload
            for processed_image in processed_images: # Iterate through each processed image variant
                output_key = processed_image['key'] # Get the S3 key for the processed image
                output_data = processed_image['data'] # Get the binary data of the processed image
                content_type = processed_image['content_type'] # Get the content type of the processed image
                
                s3_client.put_object( # Upload the processed image to S3
                    Bucket=processed_bucket, # Specify the target bucket
                    Key=output_key, # Specify the S3 key for the uploaded object
                    Body=output_data, # Provide the image data
                    ContentType=content_type, # Set the content type
                    Metadata={ # Add custom metadata to the S3 object
                        'original-key': key, # Store the original S3 key
                        'processed-by': 'lambda-image-processor', # Identify the processor
                        'request-id': request_id, # Store the Lambda request ID
                        'processing-time-ms': str(int(process_time)) # Store the processing time
                    }
                )
            
            upload_time = (time.time() - upload_start) * 1000 # Calculate upload time in milliseconds
            logger.info(f"REQUEST_ID: {request_id} - Uploaded {len(processed_images)} variants in {upload_time:.2f}ms") # Log the upload time and number of variants
            
            processed_count += len(processed_images) # Increment the total count of processed images
            logger.info(f"REQUEST_ID: {request_id} - Successfully processed {len(processed_images)} variants of {key}") # Log successful processing of variants
        
        # Calculate total execution time
        total_time = (time.time() - start_time) * 1000 # Calculate the total execution time of the Lambda function
        
        # Publish custom metrics to CloudWatch
        publish_metrics( # Call the helper function to publish metrics
            function_name=context.function_name if context else 'local', # Pass the function name or 'local'
            processing_time=total_time, # Pass the total processing time
            image_count=len(event['Records']), # Pass the number of S3 records (original images)
            success=True # Indicate successful execution
        )
        
        logger.info(f"REQUEST_ID: {request_id} - COMPLETED - Total time: {total_time:.2f}ms, Processed {processed_count} images") # Log completion message
        
        return { # Return a success response
            'statusCode': 200, # HTTP status code for success
            'body': json.dumps({ # JSON body with details
                'message': 'Image processed successfully', # Success message
                'processed_images': processed_count, # Number of processed image variants
                'execution_time_ms': int(total_time), # Total execution time
                'request_id': request_id # The request ID
            })
        }
        
    except Exception as e:
        error_time = (time.time() - start_time) * 1000 # Calculate the time until the error occurred
        logger.error(f"REQUEST_ID: {request_id} - ERROR processing image after {error_time:.2f}ms: {str(e)}", exc_info=True) # Log the error with traceback
        
        # Publish failure metrics
        if context: # Only publish metrics if context is available
            publish_metrics( # Call the helper function to publish metrics
                function_name=context.function_name, # Pass the function name
                processing_time=error_time, # Pass the time until error
                image_count=len(event.get('Records', [])), # Pass the number of S3 records (original images)
                success=False # Indicate failure
            )
        
        return { # Return an error response
            'statusCode': 500, # HTTP status code for internal server error
            'body': json.dumps({ # JSON body with error details
                'error': str(e), # The error message
                'request_id': request_id # The request ID
            })
        }


def process_image(image_data, original_key, request_id='unknown'):
    """
    Process the image: create compressed versions and convert formats.
    
    Args:
        image_data: Raw image data
        original_key: Original S3 key
        request_id: Request ID for logging
        
    Returns:
        List of processed image dictionaries
    """
    processed_images = []
    
    try:
        # Open the image
        image = Image.open(BytesIO(image_data)) # Open the image from the binary data using BytesIO
        
        # Convert RGBA to RGB for JPEG compatibility
        if image.mode in ('RGBA', 'LA', 'P'): # Check if the image has transparency (RGBA, LA) or is palette-based (P)
            background = Image.new('RGB', image.size, (255, 255, 255)) # Create a new white background image
            if image.mode == 'P': # If palette mode
                image = image.convert('RGBA') # Convert to RGBA first to handle transparency correctly
            background.paste(image, mask=image.split()[-1] if image.mode in ('RGBA', 'LA') else None) # Paste the image onto the white background using the alpha channel as a mask
            image = background # Update the image variable to point to the flattened image
        elif image.mode != 'RGB': # If not RGB and not one of the transparency modes handled above
            image = image.convert('RGB') # Convert directly to RGB
        
        # Get original format and dimensions
        original_format = image.format or 'JPEG' # Get the original format, default to JPEG if unknown
        width, height = image.size # Get the dimensions of the image
        
        logger.info(f"REQUEST_ID: {request_id} - Original image: {width}x{height}, format: {original_format}") # Log the original image details
        
        # Resize if image is too large
        if width > MAX_DIMENSION or height > MAX_DIMENSION: # Check if width or height exceeds the maximum allowed dimension
            ratio = min(MAX_DIMENSION / width, MAX_DIMENSION / height) # Calculate the scaling ratio to fit within MAX_DIMENSION
            new_width = int(width * ratio) # Calculate the new width
            new_height = int(height * ratio) # Calculate the new height
            image = image.resize((new_width, new_height), Image.Resampling.LANCZOS) # Resize the image using high-quality resampling
            logger.info(f"REQUEST_ID: {request_id} - Resized to: {new_width}x{new_height}") # Log the new dimensions
        
        # Generate base filename
        base_name = os.path.splitext(original_key)[0] # Extract the filename without extension from the S3 key
        unique_id = str(uuid.uuid4())[:8] # Generate a short unique ID to prevent filename collisions
        
        # Create multiple variants
        variants = [ # Define the list of image variants to generate
            {'format': 'JPEG', 'quality': 85, 'suffix': 'compressed'}, # High quality JPEG
            {'format': 'JPEG', 'quality': 60, 'suffix': 'low'}, # Low quality JPEG
            {'format': 'WEBP', 'quality': 85, 'suffix': 'webp'}, # WebP format
            {'format': 'PNG', 'quality': None, 'suffix': 'png'} # PNG format (lossless)
        ]
        
        for variant in variants: # Iterate over each variant configuration
            output = BytesIO() # Create an in-memory byte stream for the output
            save_format = variant['format'] # Get the target format
            
            if variant['quality']: # Check if quality setting is provided
                image.save(output, format=save_format, quality=variant['quality'], optimize=True) # Save with specific quality
            else:
                image.save(output, format=save_format, optimize=True) # Save without explicit quality (e.g., for PNG)
            
            output.seek(0) # Reset the stream position to the beginning
            
            # Generate output key
            extension = save_format.lower() # Get lowercase extension
            if extension == 'jpeg': # Normalize jpeg extension
                extension = 'jpg'
            
            output_key = f"{base_name}_{variant['suffix']}_{unique_id}.{extension}" # Construct the new S3 key
            
            # Determine content type
            content_type_map = { # Map formats to MIME types
                'JPEG': 'image/jpeg',
                'PNG': 'image/png',
                'WEBP': 'image/webp'
            }
            content_type = content_type_map.get(save_format, 'image/jpeg') # Get content type, default to jpeg
            
            processed_images.append({ # Add the processed image details to the list
                'key': output_key, # S3 Key
                'data': output.getvalue(), # Binary data
                'content_type': content_type, # MIME type
                'format': save_format, # Image format
                'quality': variant['quality'] # Quality setting used
            })
            
            logger.info(f"REQUEST_ID: {request_id} - Created variant: {output_key} ({save_format}, quality: {variant['quality']})") # Log creation
        
        # Create thumbnail
        thumbnail = image.copy() # Create a copy of the image for the thumbnail
        thumbnail.thumbnail((300, 300), Image.Resampling.LANCZOS) # Create a thumbnail (preserves aspect ratio, max 300x300)
        thumb_output = BytesIO() # Create byte stream for thumbnail
        thumbnail.save(thumb_output, format='JPEG', quality=80, optimize=True) # Save thumbnail as JPEG
        thumb_output.seek(0) # Reset stream position
        
        processed_images.append({ # Add thumbnail to processed list
            'key': f"{base_name}_thumbnail_{unique_id}.jpg", # Thumbnail filename
            'data': thumb_output.getvalue(), # Thumbnail data
            'content_type': 'image/jpeg', # MIME type
            'format': 'JPEG', # Format
            'quality': 80 # Quality
        })
        
        logger.info(f"REQUEST_ID: {request_id} - Created thumbnail: {base_name}_thumbnail_{unique_id}.jpg") # Log thumbnail creation
        
        return processed_images # Return the list of all processed images
        
    except Exception as e:
        logger.error(f"REQUEST_ID: {request_id} - Image processing failed: {str(e)}", exc_info=True) # Log any errors with traceback
        raise # Re-raise the exception


def publish_metrics(function_name, processing_time, image_count, success):
    """
    Publish custom metrics to CloudWatch.
    
    Args:
        function_name: Name of the Lambda function
        processing_time: Processing time in milliseconds
        image_count: Number of images processed
        success: Whether processing was successful
    """
    try:
        metrics = [ # Define a list of metric dictionaries to publish
            {
                'MetricName': 'ProcessingTime', # Name of the metric for processing duration
                'Value': processing_time, # The actual time taken in milliseconds
                'Unit': 'Milliseconds', # Unit of measurement
                'Timestamp': datetime.utcnow() # Time of the metric event (UTC)
            },
            {
                'MetricName': 'ImagesProcessed', # Name of the metric for count of images
                'Value': image_count, # Number of images processed in this batch
                'Unit': 'Count', # Unit is a count
                'Timestamp': datetime.utcnow() # Time of the metric event
            },
            {
                'MetricName': 'ProcessingSuccess' if success else 'ProcessingFailure', # Dynamic name based on success status
                'Value': 1, # Value is 1 (binary indicator of success/failure occurrence)
                'Unit': 'Count', # Unit is a count
                'Timestamp': datetime.utcnow() # Time of the metric event
            }
        ]
        
        for metric in metrics: # Iterate through each metric defined above
            cloudwatch.put_metric_data( # Call the CloudWatch API to put metric data
                Namespace='ImageProcessor/Lambda', # Define the custom namespace for these metrics
                MetricData=[{ # List of metric data points (sending one at a time here)
                    'MetricName': metric['MetricName'], # Set the metric name
                    'Value': metric['Value'], # Set the metric value
                    'Unit': metric['Unit'], # Set the unit
                    'Timestamp': metric['Timestamp'], # Set the timestamp
                    'Dimensions': [ # Define dimensions to categorize the metric
                        {
                            'Name': 'FunctionName', # Dimension name
                            'Value': function_name # Dimension value (the Lambda function name)
                        }
                    ]
                }]
            )
        
        logger.debug(f"Published {len(metrics)} custom metrics to CloudWatch") # Log debug message indicating success
        
    except Exception as e: # Catch any exceptions during metric publishing
        # Don't fail the function if metrics publishing fails
        logger.warning(f"Failed to publish metrics: {str(e)}") # Log a warning instead of raising an error
