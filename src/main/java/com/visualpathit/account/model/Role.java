package com.visualpathit.account.model;

import javax.persistence.*;
import java.util.Set;
<<<<<<< HEAD
/**{@author waheedk} !*/
=======
/**{@author imrant} !*/
>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
@Entity
@Table(name = "role")
public class Role {
	/** the id field !*/
    private Long id;
    /** the name field !*/
    private String name;
    /** the user field !*/
    private Set<User> users;
    /** {@inheritDoc}} !*/
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    /**
     * {@link Role#id}
     !*/
    public Long getId() {
        return id;
    }
    /** {@inheritDoc}} !*/
<<<<<<< HEAD
    public final void setId(final Long id) {
=======
    public  void setId(final Long id) {
>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
        this.id = id;
    }
    /**
     * {@link Role#name}
     !*/
    public String getName() {
        return name;
    }
    /** {@inheritDoc}} !*/
<<<<<<< HEAD
    public final void setName(final String name) {
=======
    public  void setName(final String name) {
>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
        this.name = name;
    }
    /**
     * {@inheritDoc}} 
     !*/
<<<<<<< HEAD
    @ManyToMany(mappedBy = "roles")
    /**
     * {@link Role#id}
     !*/
    public Set<User> getUsers() {
=======
    @ManyToMany(fetch = FetchType.EAGER, mappedBy = "roles",cascade = CascadeType.ALL)
    /**
     * {@link Role#id}
     !*/
    public Set <User> getUsers() {
>>>>>>> 5ee292ba1cad632882cff41c5b1e9ca2f78f89bb
        return users;
    }
    /**
     * {@inheritDoc}} 
     !*/
    public final void setUsers(Set<User> users) {
        this.users = users;
    }
}
