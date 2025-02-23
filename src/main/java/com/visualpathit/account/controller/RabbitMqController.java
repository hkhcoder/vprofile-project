// package com.visualpathit.account.controller;

// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.stereotype.Controller;
// import org.springframework.web.bind.annotation.GetMapping;
// import org.springframework.web.servlet.ModelAndView;

// import com.rabbitmq.client.Connection;
// import com.rabbitmq.client.ConnectionFactory;
// import com.visualpathit.account.utils.RabbitMqUtil;

// import java.io.IOException;
// import java.util.concurrent.TimeoutException;

// @Controller
// public class RabbitMqController {

//     @Autowired
//     private RabbitMqUtil rabbitMqUtil;

//     @GetMapping("/user/rabbit")
//     public ModelAndView checkRabbitMqStatus() {
//         ModelAndView modelAndView = new ModelAndView();
//         ConnectionFactory factory = new ConnectionFactory();
//         factory.setHost(RabbitMqUtil.getRabbitMqHost());
//         factory.setPort(Integer.parseInt(RabbitMqUtil.getRabbitMqPort()));
//         factory.setUsername(RabbitMqUtil.getRabbitMqUser());
//         factory.setPassword(RabbitMqUtil.getRabbitMqPassword());

//         Connection connection = null;
//         try {
//             connection = factory.newConnection();
//             if (connection.isOpen()) {
//                 modelAndView.setViewName("rabbitmq");
//             } else {
//                 modelAndView.setViewName("rabbitmq-error");
//             }
//         } catch (IOException | TimeoutException e) {
//             modelAndView.setViewName("rabbitmq-error");
//         } finally {
//             if (connection != null) {
//                 try {
//                     connection.close();
//                 } catch (IOException e) {
//                     // Log the exception if needed
//                 }
//             }
//         }
//         return modelAndView;
//     }
// }


package com.visualpathit.account.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.ModelAndView;

import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.visualpathit.account.utils.RabbitMqUtil;

import java.io.IOException;
import java.util.concurrent.TimeoutException;
import javax.net.ssl.SSLContext;

@Controller
public class RabbitMqController {

    @Autowired
    private RabbitMqUtil rabbitMqUtil;

    @GetMapping("/user/rabbit")
    public ModelAndView checkRabbitMqStatus() {
        ModelAndView modelAndView = new ModelAndView();
        ConnectionFactory factory = new ConnectionFactory();

        try {
            // Fetch RabbitMQ Configurations
            String rabbitMqHost = RabbitMqUtil.getRabbitMqHost();
            int rabbitMqPort = Integer.parseInt(RabbitMqUtil.getRabbitMqPort());
            String rabbitMqUser = RabbitMqUtil.getRabbitMqUser();
            String rabbitMqPassword = RabbitMqUtil.getRabbitMqPassword();

            // Debug: Print connection details
            System.out.println("Connecting to RabbitMQ...");
            System.out.println("Host: " + rabbitMqHost);
            System.out.println("Port: " + rabbitMqPort);
            System.out.println("User: " + rabbitMqUser);

            // Set Connection Properties
            factory.setHost(rabbitMqHost);
            factory.setPort(rabbitMqPort);
            factory.setUsername(rabbitMqUser);
            factory.setPassword(rabbitMqPassword);

            // Enable SSL for Amazon MQ (RabbitMQ)
             factory.useSslProtocol(SSLContext.getDefault());

            // Establish Connection
            Connection connection = factory.newConnection();
            if (connection.isOpen()) {
                System.out.println("RabbitMQ Connection Successful!");
                modelAndView.setViewName("rabbitmq");
            } else {
                System.out.println("RabbitMQ Connection Failed!");
                modelAndView.setViewName("rabbitmq-error");
            }

            // Close Connection
            connection.close();

        } catch (IOException | TimeoutException e) {
            System.err.println("Error connecting to RabbitMQ: " + e.getMessage());
            e.printStackTrace();
            modelAndView.setViewName("rabbitmq-error");
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
            modelAndView.setViewName("rabbitmq-error");
        }

        return modelAndView;
    }
}
