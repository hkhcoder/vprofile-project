package com.visualpathit.account.service;

<<<<<<< HEAD
import com.visualpathit.account.model.User;

/** {@author waheedk}!*/
=======
import java.util.List;

import com.visualpathit.account.model.User;

/** {@author imrant}!*/
>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
public interface UserService {
	/** {@inheritDoc}} !*/
    void save(User user);
    /** {@inheritDoc}} !*/
    User findByUsername(String username);
<<<<<<< HEAD
=======
    User findById(long id);
    /*public void updateUser(User user);*/
    public List <User> getList();
>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
}
