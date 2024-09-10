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

@Controller
public class RabbitMqController {

    @Autowired
    private RabbitMqUtil rabbitMqUtil;

    @GetMapping("/user/rabbit")
    public ModelAndView checkRabbitMqStatus() {
        ModelAndView modelAndView = new ModelAndView();
        ConnectionFactory factory = new ConnectionFactory();

        String host = RabbitMqUtil.getRabbitMqHost();
        String port = RabbitMqUtil.getRabbitMqPort();
        String username = RabbitMqUtil.getRabbitMqUser();
        String password = RabbitMqUtil.getRabbitMqPassword();

        // Log the values to ensure they are being read correctly
        System.out.println("Connecting to RabbitMQ with the following settings:");
        System.out.println("Host: " + host);
        System.out.println("Port: " + port);
        System.out.println("Username: " + username);
        System.out.println("Password: " + password);

        factory.setHost(host);
        factory.setPort(Integer.parseInt(port));
        factory.setUsername(username);
        factory.setPassword(password);

        Connection connection = null;
        try {
            connection = factory.newConnection();
            if (connection.isOpen()) {
                modelAndView.setViewName("rabbitmq");
            } else {
                modelAndView.setViewName("rabbitmq-error");
            }
        } catch (IOException | TimeoutException e) {
            modelAndView.setViewName("rabbitmq-error");
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (IOException e) {
                    // Log the exception if needed
                }
            }
        }
        return modelAndView;
    }
}

