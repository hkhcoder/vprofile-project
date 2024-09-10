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
        factory.setHost(RabbitMqUtil.getRabbitMqHost());
        factory.setPort(Integer.parseInt(RabbitMqUtil.getRabbitMqPort()));
        factory.setUsername(RabbitMqUtil.getRabbitMqUser());
        factory.setPassword(RabbitMqUtil.getRabbitMqPassword());

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
