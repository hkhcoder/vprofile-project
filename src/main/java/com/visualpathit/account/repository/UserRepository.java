package com.visualpathit.account.repository;

<<<<<<< HEAD
=======
import java.util.List;

>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
import org.springframework.data.jpa.repository.JpaRepository;

import com.visualpathit.account.model.User;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
<<<<<<< HEAD
=======
    User findById(long id);
    /*public void updateUser(User user)*/;
    
>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
}
