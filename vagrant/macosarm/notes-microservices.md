multi stage docker file 
first stage for buidling the npm project uses the node:14 image 
build an anglular application : web app 
second stage used an nginx image and copies the build artifacts from dist/client to the html folder in the nginx image 
we then copy an nginx config from the repo to the nginx image destination configuration location in etc nginx/conf.d/default.

we expose then the port 4200 

for java apps we build them using an open jdk app and install maven the install using the cmd mvn install -DskipTests

the open jdk is also used to run the java app as it contains the JRE needed to run the java app : 
entrypoint java -jar cxp-0.1.jar 

we have then nginx as an api gateway we mount the conf file as a volume to the appropiate location, this avoids building the image via a dockerfile that contains a copy command. 
We can directly reference the service and specify the volume and the mount.

depends on in compose specifies that the the containers specified as dependencies shoudl eb built and run before the service in question. 



## CMD vs ENTRYPOINT in Dockerfiles

### CMD (Command)
- **Purpose**: Provides default arguments for the container
- **Behavior**: Can be overridden when running `docker run`
- **Syntax**: 
  - `CMD ["executable", "param1", "param2"]` (exec form - recommended)
  - `CMD executable param1 param2` (shell form)
- **Use Case**: Default command that users might want to override
- **Example from app/Dockerfile**: 
  ```dockerfile
  CMD ["catalina.sh", "run"]
  ```
  - This can be overridden: `docker run <image> /bin/bash`

### ENTRYPOINT (Entry Point)
- **Purpose**: Sets the main command that always runs
- **Behavior**: Cannot be overridden, but can accept additional arguments
- **Syntax**:
  - `ENTRYPOINT ["executable", "param1", "param2"]` (exec form - recommended)
  - `ENTRYPOINT executable param1 param2` (shell form)
- **Use Case**: When you want the container to always run a specific command
- **Example**:
  ```dockerfile
  ENTRYPOINT ["java", "-jar", "app.jar"]
  ```
  - Additional args are appended: `docker run <image> --debug` becomes `java -jar app.jar --debug`

### Key Differences:
1. **Override**: CMD can be completely overridden, ENTRYPOINT cannot
2. **Arguments**: ENTRYPOINT always runs, CMD provides defaults
3. **Combination**: Can use both together - ENTRYPOINT sets the command, CMD provides default args
   ```dockerfile
   ENTRYPOINT ["java", "-jar"]
   CMD ["app.jar"]
   ```
   - Default: `java -jar app.jar`
   - Override: `docker run <image> other-app.jar` → `java -jar other-app.jar`

### Best Practices:
- Use **ENTRYPOINT** when you want a fixed command that always runs
- Use **CMD** when you want a default command that users might override
- Use **exec form** `["cmd", "arg"]` instead of shell form for better signal handlingxpose the port 9000
