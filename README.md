# `mail_lib.sh`
This script is used every day to send a responsive html message from Production/Development Unix Systems.
Regarding the responsive, I'm not an expert about HTML. But you could attach files, give a priority to your email ....

`How to`

Simple ...

```plain

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
        add_info_to_html "Error with image" 0
        
        html_email
```

Easy ...

