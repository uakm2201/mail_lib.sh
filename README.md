# mail_lib.sh

## _Attach this library to your bash script and send easily an HTML email._


This script is used every day to send a responsive html message from Production/Development Unix Systems.

![](https://github.com/uakm2201/mail_lib.sh/blob/main/email.png)

![](https://github.com/uakm2201/mail_lib.sh/blob/main/email_small.png)


# Features
- Insert a new line to your email using add_info_to_html function.
- Add some small icons (Ok, Error, Warning) to have a visual informations.
- Quickly add an attached files.
- Useful functionalities (Logo, Autozip ..) 

`How to ? `

Simple ...

```sh

#!/bin/bash 
#       -------------------------------------------------------------------
#       Include basic functions non specific to this shell
#       -------------------------------------------------------------------

        OLD_LPATH=${LPATH}
        LPATH=/opt/admin/bin
        . $LPATH/../lib/mail_lib.sh
        LPATH=${OLD_LPATH}
        
# -------------------------------------------------------------------
# Program starts here
# -------------------------------------------------------------------

        MAIL_RECI="myadress@mycompany.com"
        HTML_TITLE="The Title of my email"
        MAIL_SUBJECT="First Email Test"
        
        add_info_to_html "1rst Line"
        add_info_to_html "Error with image." 1
        
        html_email
```


`How to attach a file ?`

Before the html_email instruction, add this line:
      
```sh

        #add_file_to_mail "/Full Path of my file" "Name of displayed file on the email"
        add_file_to_mail "/tmp/example.txt" "example.txt"
```   

`How to attach a logo ?`

```plain    
        #Use the constant LOGO    
        LOGO=1    
```       

`Want to validate something ?`

```sh
       # 0 = Error, 1 = Ok, 2 = Warning 
       add_info_to_html "All good." 0
```       

Easy ....

