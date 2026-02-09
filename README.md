# Prerequisites
#
- JDK 11 
- Maven 3 
- MySQL 8

# Technologies 
- Spring MVC
- Spring Security
- Spring Data JPA
- Maven
- JSP
- Tomcat
- MySQL
- Memcached
- Rabbitmq
- ElasticSearch

# Database
Here,we used Mysql DB 
sql dump file:
- /src/main/resources/db_backup.sql
- db_backup.sql file is a mysql dump file.we have to import this dump to mysql db server
- > mysql -u <user_name> -p accounts < db_backup.sql


---

## Quality Gates

In Sonar Qube, We can create a Quality Gates and add Condition for overall code (Bugs)

Attach the Qualtiy gates to the projects. 

- Sonar qube will send result to the jenkins. We need to add webhook in the Sonarqube

- Add Stages for Quality Gates in the Jenkin Pipeline

---

## Publish Artifact to Nexus Repos

We need to upload our application artifact to the nexus repos (vprofile-release) and need to store the file with timestamp and version

- In code we need to apply timestamp of the war file 

-  Manage Jenkins -> Tool -> Build Timestamp

- Write code to upload artifact to the nexus 

- Check in the nexus the code will be available

===

## Tomcat Playbook

- Write a Playbook to install tomcat server in the App Server. 

- From Jenkins Master Server, we will execute ansible playbook to install tomat application in the App Server 

- Tomcat Playbook Steps

  1. Store Variable of the Tomcat Binary URL that we need to download from internet

  2. Install Java in Ubuntu, Centos using ansible module `apt or yum`

  3. Download Tar file using module `get_url`

  4. Create a Group called "`TOMCAT`"

  5. Add Tomcat user and assign home dir and shell has NoLogin

  6. Create a Dir in the Server to store the tomcat Archive file

  7. Extract Tomcat file and store in the Dir /usr/local/tomcat. Store the Output in a Variable (Register)

  8. Synchronize tmp and local user folder for tomcat

  9. Change Ownership for the `/usr/local/tomcat8` to `Tomcat` User

  10. Setup Tomcat SVC File for Centos and Ubuntu using module `template`

  11. Reload the Systemd file for tomcat server using module `systemd`

  12. Start the Tomcat Server using module `service`

---
## Deployment Playbook

This Playbook will download and deploy artifacts in the App server

1. Create a `Variable` to get the timestamp and usinmg this timestamp we will create a backupfile_name of the artifacts

2. Using module get_url download artifacts from nexus. Nexus has Dynamic URL. We will get the Jenkins Variables in the ansible playbook 

3. Before downloading and deploying artifacts we need to take backup for the existing Application running in the tomcat Server 

4. Stop the tomcat Service

5. Try Block to archive and deploy

6. Copy the Tomcat ROOT File in the same dir

7. Delete the Current Artifacts

8. Start the Tomcat Service 


```yaml
- name: Setup Tomcat 8 and Deploy Artifacts
  hosts: appserver
  become: yes

  vars:
    timestamp: "{{ ansible_date_time.date }}_{{ ansible_date_time.hour }}_{{ ansible_date_time.minute }}"

  tasks:
    - name: Download Artifacts from the Nexus Artifacts
      get_url:
        url: "http://{{USER}}:{{PASS}}@{{nexusip}}:8081/repository/{{reponame}}/{{groupid}}/{{time}}/{{build}}/{{vprofile_version}}"
        dest: "/tmp/vproapp-{{ vprofile_version }}"
      register: wardeploy # Store the result of this task 
      # Add tags:
      tags:
        - deploy 

    # Task will check if the artifact is already present in the server or not
    - ansible.builtin.stat:
        path: "/usr/local/tomcat8/webapps/ROOT"
      register: artifact_stat
      tags:
        - deploy

    # Task will stop the running tomcat service in the server
    - name: Stop Tomcat service
      ansible.builtin.service:
        name: tomcat
        state: stopped
      tags:
        - deploy

    # Using Try will take Backup and deploy the Artifacts
    - name: Try Backup and deploy
      block:
        - name: Archive Root Directory with timestamp
          ansible.builtin.archive:
            path: "/usr/local/tomcat8/webapps/ROOT"
            dest: "/opt/ROOT_{{ timestamp }}.tqz"
          when: artifact_stat.stat.exists # This task will only run if the artifact already exist in the server
          register: archive_info
          tags:
            - deploy

        - name: Copy ROOT Directory with OLD_Root directory
          ansible.builtin.shell:
            cmd: cp -r ROOT old_ROOT
            chdir: /usr/local/tomcat8/webapps/

        - name: Delete the Current Artifacts
          ansible.builtin.file:
            path: "{{ item }}"
            state: absent
          when: archive_info.changed
          loop:
            - /usr/local/tomcat8/webapps/ROOT
            - /usr/local/tomcat8/webapps/ROOT.war
          tags:
            - deploy

        - name: Try Deploy artifact else restore from previous old root 
          block:
            - name: Deploy Vprofile Artifacts
              copy:
                src: "/tmp/vproapp-{{ vprofile_version }}"
                dest: /usr/local/tomcat8/webapps/ROOT.war
                remote_src: yes # Source file is present in the remote server
              register: deploy_info
              tags:
                - deploy
          rescue:
            - name: Restore From previous Old Root
              shell: cp -r old_ROOT ROOT
              args:
                chdir: /usr/local/tomcat8/webapps/
      rescue:
        - name: Start Tomcat server
          ansible.builtin.service:
            name: tomcat
            state: started
          
    - name: Start tomcat svc
      service:
        name: tomcat
        state: started
      when: deploy_info.changed
      tags:
       - deploy

    - name: Wait until ROOT.war is extracted to ROOT Directory
      ansible.builtin.wait_for:
        path: /usr/local/tomcat8/webapps/ROOT
      tags:
        - deploy
      

```

--- 

## Jenkins File and Inventory

Write a Jenkins File code to run the playbook

- Add Stage for Ansible 

- Create an Inventory File to store the information of the host mentioned in the Playbook

- Paste the Record of the Route Table for App Server

- Store the Nexus Credentials in the Jenkins and use the credentials in the Jenkins File

- Allow the SG for the Nexus Server to allow traffic from the App Server SG

---

## JenkinsFile For Prod

- Update the Github Weebhook with the new Jenkins URL 

- Add a new host Name in the Inventory File

- We need to delete Stage like Build, Test, Upload Artifact. Here, we will provide user input has parameter to download artifact from the Nexus Repository

- In Ansible Deploy Stage add a Variable to get the input from user

- Create a new Job in the Jenkins and mention the JenkinsFile Path in the Git