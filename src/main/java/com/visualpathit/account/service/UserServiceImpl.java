package com.visualpathit.account.service;

import com.visualpathit.account.DatabaseException;
import com.visualpathit.account.model.User;
import com.visualpathit.account.repository.RoleRepository;
import com.visualpathit.account.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;

/** {@author imrant}! */
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    @Override
    public void save(final User user) {
        try {
            user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
            user.setRoles(new HashSet<>(roleRepository.findAll()));
            userRepository.save(user);
        } catch (Exception ex) {
            // Handle any exception related to the database
            throw new DatabaseException("Database is unavailable. Please try again later.", ex);
        }
    }

    @Override
    public User findByUsername(final String username) {
        try {
            return userRepository.findByUsername(username);
        } catch (Exception ex) {
            // Handle any exception related to the database
            throw new DatabaseException("Database is unavailable. Please try again later.", ex);
        }
    }

    @Override
    public List<User> getList() {
        try {
            return userRepository.findAll();
        } catch (Exception ex) {
            // Handle any exception related to the database
            throw new DatabaseException("Database is unavailable. Please try again later.", ex);
        }
    }

    @Override
    public User findById(long id) {
        try {
            User user = userRepository.findById(id);
            if (user == null) {
                throw new DatabaseException("User not found with id: " + id);
            }
            return user;
        } catch (Exception ex) {
            // Handle any exception related to the database
            throw new DatabaseException("Database is unavailable. Please try again later.", ex);
        }
    }

}
