#!/bin/bash

#       -------------------------------------------------------------------
#
#       Shell program used as library to send a html email using bash.
#      
#
#
#       Description:
#
#
#
#       Usage:
#
#               
#
#       Options:
#
#
#
#       Last Committed    : 
#       Last Changed date : 
#       Last changed by   : 
#       ID                : 
# 
#       -------------------------------------------------------------------


#       -------------------------------------------------------------------
#       Constants
#       -------------------------------------------------------------------

        BOUNDARY=123456 #Comment the below line if the /dev/urandom is not available on your system.
        BOUNDARY=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-8} | head -n 1`
        NL=$'\n'
        
        # Change this color depending on your flavours ...
        
        HTML_BG_COLOR="#f0f0f0"
        HTML_HEAD_BG_COLOR="#ffffff"
        HTLM_HEAD_FONT_COLOR="#04364c"
        HTML_BODY_BG_COLOR="#ffffff"
        
        
        KEEP_MAIL=0               #Constant used to keep the mail as a file (Value=1) or not (Value=0)
        LOGO=0                    #Constant used to add a logo (Value=1) or not (Value=0)
        DEBUG_EMAIL_TABLE=0       #Put to 1 if you would like to have a border on each table of your email.
        
#       -------------------------------------------------------------------
#       Constants used by the library. Don't change it.
#       -------------------------------------------------------------------        

        REGEX_TAG_EMAIL='^<!--.*\bEMAIL TAG\b.*-->'
        HTML_TITLE=""
        
        
        
function check_bin
{
  
#       -----------------------------------------------------------------------
#       Function to check if a binary is present.
#       Argument :
#       1: Name of the binary
#
#       Return full path of binary or empty string.
#       -----------------------------------------------------------------------


        if [ "${BIN_WHICH}" != "" ]; then
          INT_BIN_SEARCH=`${BIN_WHICH} $1 2>/dev/null`
          if [ "$?" = 1 ]; then
            INT_BIN_SEARCH=""
          fi
        else 
           INT_BIN_SEARCH=""
        fi
        echo "${INT_BIN_SEARCH}"  
}


function init_email
{

#       -----------------------------------------------------------------------
#       Function to init the email library.
#       Argument : None
#
#       Exit if we can't create a temporary file.
#       -----------------------------------------------------------------------


        if [ "${INT_EMAIL_TMP}" = "" ]; then
          if [ -d ~/tmp ]; then
            TEMP_DIR=~/tmp
          else
            TEMP_DIR=/tmp
          fi
          INT_EMAIL_TMP=$(mktemp  "${TEMP_DIR}/bash_email.$$.XXXXXX")
          if [ "${INT_EMAIL_TMP}" = "" ]; then
            echo "cannot create mail temp file!"
            exit 1
          fi
          INT_TAG_EMAIL_COUNTER=0
          if [ -f "${KEEP_MAIL_FILE}" ]; then
            cat "${KEEP_MAIL_FILE}" > "${INT_EMAIL_TMP}"
            search_section
            for i in ${INT_MAIL_SECTION}
            do
              INT_START_LINE=`echo $i | awk -F"," {'print $1'}`
              INT_END_LINE=`echo $i | awk -F"," {'print $2'}`
              INT_SP_MAIL_SECTION=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
              INT_TAG_SECTION=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /TAG/) print $(i+1)}'}`
              if [ "${INT_TAG_SECTION}" -gt "${INT_TAG_EMAIL_COUNTER}" ]; then
                INT_TAG_EMAIL_COUNTER="${INT_TAG_SECTION}"
              fi
            done
          fi      
        fi
}

function mime_header
{

#       -----------------------------------------------------------------------
#       Function to add to mime header on the variable MSG.
#       Argument : None
#
#       -----------------------------------------------------------------------


        MSG=""
        if [ "${MAIL_SENDER}" != "" ]; then
          MSG="${MSG}From: ${MAIL_SENDER}${NL}"
        fi
        #To
        MSG="${MSG}To: ${MAIL_RECI}${NL}"
        #Cc
        if [ "${MAIL_CC}" != "" ]; then
          MSG="${MSG}Cc: ${MAIL_CC}${NL}"
        fi
        #Bcc
        if [ "${MAIL_BC}" != "" ]; then
          MSG="${MSG}Bc: ${MAIL_BC}${NL}"
        fi
        MSG="${MSG}Subject: ${MAIL_SUBJECT}${NL}"
        if [ "$MAIL_PRIORITY" = "" ] ; then 
          MAIL_PRIORITY="3"
        fi
        MSG="${MSG}X-Priority: ${MAIL_PRIORITY}${NL}"
        MSG="${MSG}MIME-Version: 1.0${NL}"
        MSG="${MSG}Content-Type: multipart/mixed; boundary=${BOUNDARY}${NL}"
        MSG="${MSG}${NL}"
} 


function mime_add_icon
{

#       -----------------------------------------------------------------------
#       Function to add on the mime header an image 
#       (OK, NOTOK, WARNING, and LOGO)
#       Argument : None
#
#       -----------------------------------------------------------------------

        WARNING=0
        OK=0
        NOTOK=0
        
        STRING_OK=`grep cid:ok ${INT_EMAIL_TMP} || grep '^<!--.*\bEMAIL TAG\b.*\bimg\b.*-->' ${INT_EMAIL_TMP} | awk '{ for (i=1;i<=NF;i++) { tmp=match($i,/img:1/); if (tmp) {print $(i)}}}' `
        STRING_NOTOK=`grep cid:notok ${INT_EMAIL_TMP} || grep '^<!--.*\bEMAIL TAG\b.*\bimg\b.*-->' ${INT_EMAIL_TMP} | awk '{ for (i=1;i<=NF;i++) { tmp=match($i,/img:0/); if (tmp) {print $(i)}}}' `  
        STRING_WARNING=`grep cid:warning ${INT_EMAIL_TMP} || grep '^<!--.*\bEMAIL TAG\b.*\bimg\b.*-->' ${INT_EMAIL_TMP} | awk '{ for (i=1;i<=NF;i++) { tmp=match($i,/img:2/); if (tmp) {print $(i)}}}' `
        if [ "$STRING_OK" != "" ]; then
          OK=1
        fi
        if [ "$STRING_WARNING" != "" ]; then
                WARNING=1
        fi
        if [ "$STRING_NOTOK" != "" ]; then
                NOTOK=1
        fi
        
        if [ "$OK" = "1" ]; then  
          MSG="${MSG}--$BOUNDARY${NL}"
          MSG="${MSG}Content-Type: image/gif${NL}"  
          MSG="${MSG}Content-Transfer-Encoding: base64${NL}"
          MSG="${MSG}Content-ID: <ok>${NL}"
          MSG="${MSG}Content-Disposition: inline;filename=\"ok.gif\"${NL}"
          MSG="${MSG}${NL}"
          MSG="${MSG}R0lGODlhDwAPALMNAJTPZf///0aSOP/+/////f/9/v39/f7/+v//+/3//P/9//3/${NL}"
          MSG="${MSG}/v7+/v///wAAAAAAACH5BAEAAA0ALAAAAAAPAA8AAARMsEkZap24VcH5xQEHjKM3${NL}"
          MSG="${MSG}hWRaBpSgjgQgsOhLBPFcM2QwBCtUIaAABBYFks4FSAwMv9SSdIhKaUwAQjVrvZSs${NL}"
          MSG="${MSG}VrbUBYU6uszJEp5EAAA7${NL}"
          MSG="${MSG}${NL}"
        fi

        if [ "$NOTOK" = "1" ]; then 
          MSG="${MSG}--$BOUNDARY${NL}"
          MSG="${MSG}Content-Type: image/gif${NL}"  
          MSG="${MSG}Content-Transfer-Encoding: base64${NL}"
          MSG="${MSG}Content-ID: <notok>${NL}"
          MSG="${MSG}Content-Disposition: inline;filename=\"notok.gif\"${NL}"
          MSG="${MSG}${NL}"
          MSG="${MSG}R0lGODlhDwAPANU5AP/////+//8ACP7///8ACv4ACLUACf8ABv///bUAB/8BCf7/${NL}"
          MSG="${MSG}/f4ACv8AC/8BB/4BBv7+/7cABbYBCLcAB///+/BaZf7+/LQBB/3//rQACbcACbUA${NL}"
          MSG="${MSG}BfwBCP8BC/8ABLYBCvwBCrUBCvJYYrgACe1aYO1aYv4ABf3//P/+/PsAB7QBBf4A${NL}"
          MSG="${MSG}A7QACLMACv8BDP7+/v3+/+xZX7QABv/9/rYACP/9/P/9/+5bY+9ZYv///wAAAAAA${NL}"
          MSG="${MSG}AAAAAAAAAAAAAAAAACH5BAEAADkALAAAAAAPAA8AAAaqwJxQCAgELIihMgcYjDYb${NL}"
          MSG="${MSG}gwEVWA4iF4HiQRB8MoAhxdC4EQqmTgEn0AyEgwQJgFCsCghAxRAGyBQHATYzLhAB${NL}"
          MSG="${MSG}MA4cEQMAEV0pADULAwGAB3wACQQPBwUBABYPAgcMLZ8ZBA4CGBifC2ceFwAAEwwM${NL}"
          MSG="${MSG}RgMECwEQDQIqYQMSFQsIBwIEhjEGbzkICQUiHCACqiUNNCdDcRoFXQoFE3xLLwEh${NL}"
          MSG="${MSG}LAkJEnlLYrNNS0EAOw==${NL}"
          MSG="${MSG}${NL}"
        fi

        if [ "$WARNING" = "1" ]; then 
          MSG="${MSG}--$BOUNDARY${NL}"
          MSG="${MSG}Content-Type: image/gif${NL}"  
          MSG="${MSG}Content-Transfer-Encoding: base64${NL}"
          MSG="${MSG}Content-ID: <warning>${NL}"
          MSG="${MSG}Content-Disposition: inline;filename=\"warning.gif\"${NL}"
          MSG="${MSG}${NL}"
          MSG="${MSG}R0lGODlhDQANANUwAP/dUf/eU//eUf7fU8WeKf/cUP7dUMadK8adKcWcJv7eVcabKP3eUMib${NL}"
          MSG="${MSG}KMWcKv7fUf7fUP/dU8abKsecKceZKTI0M8mcKcWeJzEzMsWcKMacLv/fUv/hU//fVjEzMMSc${NL}"
          MSG="${MSG}KzYyM8SdJv/dT8mZK8ecLPzgUf/cUv3dVP/gUv/eVjMzMcedJ8ScKsWdLDUzNsWdK////wAA${NL}"
          MSG="${MSG}AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAADAALAAA${NL}"
          MSG="${MSG}AAANAA0AAAZuQJhwSBgajQgA4mhcRASBF1MoUTBSiWlDAHABNsvj6gQAAQSOowPCrQAAgUVT${NL}"
          MSG="${MSG}wfUABqXDMDF4CJ4ADAAFEkIkXAoAGAAQDwEtMAQFAwNvKgAmAwEGGSMomxwFHSIBmwEaISwW${NL}"
          MSG="${MSG}BxQEHxMXDQcTCUEAOw==${NL}"
          MSG="${MSG}${NL}"
        fi
        
        if [ "$LOGO" = "1" ]; then
          MSG="${MSG}--$BOUNDARY${NL}"
          MSG="${MSG}Content-Type: image/png${NL}"  
          MSG="${MSG}Content-Transfer-Encoding: base64${NL}"
          MSG="${MSG}Content-ID: <logo>${NL}"
          MSG="${MSG}Content-Disposition: inline;filename=\"Serca_mini.png\"${NL}"
          MSG="${MSG}${NL}"
          
          # if you prefer to add your own image, use the base64 binary and the full path of your image.
          # Take care about the type of image define by Content-Type: image/xxx on the header.
          # Here, I'm using a png image.
          #
          # INT_LOGO=`base64 /opt/share/images/Serca.png`
          
          INT_LOGO=""
          INT_LOGO="${INT_LOGO}iVBORw0KGgoAAAANSUhEUgAAAc4AAAHOCAMAAAAmOBmCAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC${NL}"
          INT_LOGO="${INT_LOGO}AK7OHOkAAADSUExURUdwTO1zIulgRtQdI+ZAYAc3TuheSehcTOY5ZNITJgY2TehTU+YzaeppM9EN${NL}"
          INT_LOGO="${INT_LOGO}LexuK+10Hwc2TedGW+c6ZOtoN+piQuhAYAc1TehWSulaSOtqM9QWLgU1TOdTSuc/YQAmQAQzTOYy${NL}"
          INT_LOGO="${INT_LOGO}audWROxGPuhVUQAwR+hWSwc1TOpiRAY1TOpfSupfRwY1TdgsHOdGWwY1TQY2TulYSehaTt4yPOQy${NL}"
          INT_LOGO="${INT_LOGO}XtgeMeg6ZdspN98uSu50IQk4T+pgTdUWIdUbHdMQJ+hAZO95Hec0bOg6aOlHX9YiGepZUX1EAPYA${NL}"
          INT_LOGO="${INT_LOGO}AAA6dFJOUwDq6P38sPH7/P7l/fru//f3nvzy+Pf20V875/w8KOkHJe4VB/IUTfSwTcCZe/3yZIt7${NL}"
          INT_LOGO="${INT_LOGO}1/2Q5MnHqs5MZqbQAAAVtElEQVR42uydW2/aWBSFB7CwLcBEhlgJVpBIoqiaUZBSkjQVvgAu//8v${NL}"
          INT_LOGO="${INT_LOGO}zV57H0M6T3geHFda35Cp+lA/nJW1b+dw/NdfhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQggh${NL}"
          INT_LOGO="${INT_LOGO}hBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQ${NL}"
          INT_LOGO="${INT_LOGO}QgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEII${NL}"
          INT_LOGO="${INT_LOGO}IYRcxt3Ny4/nX8/P+vM8+fnt5vaeq/JnIkIK8j9Tc75YzCeL6bT385Zr84fx8parkgrk3FxPFvPp${NL}"
          INT_LOGO="${INT_LOGO}YjLt9a6uet/uuER/DA9vef6c/xr8OvHcv4acas7eVa+32/UeuE5/hjGfB3kuH7FnrehmKHIu5nMx${NL}"
          INT_LOGO="${INT_LOGO}5wTmvNoJ/3Cpus+NKilaDlyolT+ur/vD6/5EzbmYXiHcQk8atPNiDvJMtByopGpOUdPf+pBzOJ+I${NL}"
          INT_LOGO="${INT_LOGO}ORFuxZ+Qc3dFPbvM/VuW5XWkHeSuFDoO/a2o2b+eTKQWOiVP9SfXrLt8ZIMsg5Sm6K9ci1uoufXh${NL}"
          INT_LOGO="${INT_LOGO}z4kLt2c5d9+4al2dGKSiZp45c8KeA0Tboy9q9n3UQn3UQvNJT7KnJU+BQ4Vu8hTCm1D05E+NtMe+${NL}"
          INT_LOGO="${INT_LOGO}pE4RFOFWzAlFYc7anixvOxpos0EINevkaZ3KxvePW1/Cbf8a/kS4nVgtVNuTS9dB3lTJLAvzT8lz${NL}"
          INT_LOGO="${INT_LOGO}kD8fj/7R7yN3+idzovXsUc5uqxmGEm0Has+TOfPjo6jpH4/bodZCrvXsTT/J+cTV6xgPqYTZ1PnT${NL}"
          INT_LOGO="${INT_LOGO}JU+16OjxKPZ8lGgryVPDrZlz2jvXQi9cv46RhoVYUwyqYmZZfgq1jyPzZ10LXbtw+6n1ZC3UtUgb${NL}"
          INT_LOGO="${INT_LOGO}Fiql8+fg1KrAnP6o9qf2KtKoQM3JuRainB1Ts1BzInfqGEHdqeYciZTqT5RCW9RCw/5/xvC73Q1X${NL}"
          INT_LOGO="${INT_LOGO}sFMdSlqImurPsG48T+ZUf6JV8c2cp1poeqqFOLbtEjdhoXKek6d2KjCnGFP9eazHfCiH1JwL28Nm${NL}"
          INT_LOGO="${INT_LOGO}o9I17kTJAv6ElGGWffLnSLSs/elvMYb3f6uFTM6fXMMOEaYFkqakT4ipjUo9hh8BKYOOo/5xq/nT${NL}"
          INT_LOGO="${INT_LOGO}hdvFAv50yZNtZ5cSZ6iRtkCr4pKn+lPU3KicvvkTcqo5ry3c9uox/BXXsFuhNnSlUJqZPwdukjAa${NL}"
          INT_LOGO="${INT_LOGO}PeJzPI/5tlBzeDrP10O05QmwLs0PIvWmJs8iQ7wdmJqSPKEmaiFfk+f2WI/hdY+sPpLAzNkhXkNX${NL}"
          INT_LOGO="${INT_LOGO}1Jo/B5/8mWusFXPaGOGIMZ9ve9j98x42DyN0iAfJmDrfq4tbsadueuK4kIVaSHp8NH/We9haC9kJ${NL}"
          INT_LOGO="${INT_LOGO}MPacHeJHUUS1P7PCDYVccZs/jurk6SN9Dm0MP7Rwa8enebCkU0RqytSNEVL1phvzZZv1aLS0VsX2${NL}"
          INT_LOGO="${INT_LOGO}yGzMd41Jn6uF+M2GbmXOIrKitvZndvJnnq9HsUueKG5FTvhTGIpBF/P55G/2mx1DQq35s1YUrYrz${NL}"
          INT_LOGO="${INT_LOGO}5+D7x8vL7e1vBpS/3j7dPj090ZYd5EbNGRVaCllFhD2yTRJXVbz+H897f39fvr+/8mjf12RO8Sb+${NL}"
          INT_LOGO="${INT_LOGO}O/sz3axFyTiu1tX3pvOI5Sw4jIPDYbzajxmHv2AgpGKmNkaAPz1IWYmU8TquGp4YeS9FzUMQQM39${NL}"
          INT_LOGO="${INT_LOGO}eLzirKj1QiiNirM/N56omSRVnCDSVlWjiHmXlEESHODPw2EPf664p90yKeog/YTRpiyXXrU++XMU${NL}"
          INT_LOGO="${INT_LOGO}N1SzXAYHsedhPJbPXgy6f+UKt5w6i1StWaSz0luWpReLorEKWjWphO6XpSeCwpwrqDnea8RlAm2T${NL}"
          INT_LOGO="${INT_LOGO}jyhSe0ZFIlqUnihaQU2E23jdpBKSf+7NymCpuVMU3cOe+9WeFW6LvEVRis8mOKgc3rqU5On8GTcI${NL}"
          INT_LOGO="${INT_LOGO}lTdeiV8IT6QUf86QPM2f71zkNmNtCn+igDE5EvUnQq383DQxZ+KVZSD+nP3mz/GK8/kW2xTE2lTL${NL}"
          INT_LOGO="${INT_LOGO}0SAQRcWfKG7FnIi4l8997irIqYqKlEs8cK/+HNOe7fEEOVOz01LURPpcV7U/15fnvfcKVVQAfx7g${NL}"
          INT_LOGO="${INT_LOGO}z8Mq2GvvKT9c5lYrobHZSZInDDYrK0+kXMKflz+ogjFnXikxW+VcHbRVQcQdc5jQYtcparp0J02n${NL}"
          INT_LOGO="${INT_LOGO}hFoRVfyJMV8jOeHpEpFa/Rmc/ClysldprxKKxvvDwfkzUINJXVt5Cfx5edt5t6y061x6NuZTf2qo${NL}"
          INT_LOGO="${INT_LOGO}FUU5SmhPTlnxmfhzDA2CcqYGq+BPEfTyIuZJfgVmKqiUQuUM/gwOkBL5c8V1bkvOVFZbpcSnTAI1${NL}"
          INT_LOGO="${INT_LOGO}GPwZr6v48gH8C8YO1uVYbStPk6bzsFd/cp3byp2a3NSfooHWMmWJMQLG8PHlNcwHyicPYz6vPNgY${NL}"
          INT_LOGO="${INT_LOGO}Xhy/d8Ut17kdHnTFMcNRfy5LS4AqaKO96+/rpNIpof5z/d0Yz2wML4pyoVuSc28bH6cxAswpBqsS${NL}"
          INT_LOGO="${INT_LOGO}aVOS6vIHYRem8jAlRMDWMd/YtSpsPFvj3g1W9QBBkMin1HiJMYIIdPmDYp0ieZ/HfIH4035bWAq1${NL}"
          INT_LOGO="${INT_LOGO}JaedGtirnfQcAWIlSqFS/LZsIKfukkq49dwYXvset4fNYNsWltzGKxvzOTkkAVYYIzQYtlaQE1OI${NL}"
          INT_LOGO="${INT_LOGO}0qv9iT3s2ZilULty6lR1fNibnVwtU2IMv/y4+DG3mAlKo4pNGVREkFMe6EqhgOvcEqam+NOlu1kg${NL}"
          INT_LOGO="${INT_LOGO}XaNkQB3zXd52vurA3quk0SnrMZ/tkclnH3GdW5TTitsDzhEkuiWCAhVTocu3x9brKpbySTxdLiVg${NL}"
          INT_LOGO="${INT_LOGO}l6X1PRJw9+N9SjnbYmUHtCR5arrDmC9Rg2Gkfvn2mNtQw0Cp1N5Vi9ux+nMTUc7W5HR7WPvaToi0${NL}"
          INT_LOGO="${INT_LOGO}VhFVXpPCNrZdGHQ58gsRYJtspWP4IIreuM4t8arJbWz+hJ3gzwAGk+jZpO20w2LqT2x8BlopywOD${NL}"
          INT_LOGO="${INT_LOGO}NIq4o9IWT/Ue8/40hg88NZjXYMZ3DzltF6Z0c1+UQnggtse539naHAFjBB3Dn/ewVZGySi4/93Xr${NL}"
          INT_LOGO="${INT_LOGO}zuVKuC3dGRP4c2xqpjyN0GLyrP1pU3Opa3VqO/Oqy0/g3VRaCiVJhdMIuoddauNjxwS5yu1F2/qA${NL}"
          INT_LOGO="${INT_LOGO}Fk6u6z6l2/EsG8yEXqvq5E+v1B1PjOE3kZJylVutbe3UgIZaHQCUGm4bhMglvmwGRZPEnTHBxkpa${NL}"
          INT_LOGO="${INT_LOGO}qJjRDy5ye9zuT2N486dnX1X5aPAMPbrgdmG8tQoaBPqFUQjKY9Ot9iouea50jHDQkatEzCaPiNfu${NL}"
          INT_LOGO="${INT_LOGO}XK5XuZP0QWpf0WfqbJ0P58/DwdW2kj8bqfmgXzbT74OiFEpmZRoWkd2GEjHWfo0/bQ8b/gzKZaMA${NL}"
          INT_LOGO="${INT_LOGO}+aJDITfmqxJPr4KzUFuw6/ySYQJmQ/bNL+kvGo5xvutFCrH6M97YbXD1FWKMtV/BDfxpe9iz96a1${NL}"
          INT_LOGO="${INT_LOGO}y7pau1C7sStUC72tUS9ESTmw/RLuXt+Xy+X7a/PY+CAtShxvNnqLfHi+rdFuW+DKdo6HhyfhBndD${NL}"
          INT_LOGO="${INT_LOGO}PXzm7un25Z+/Y9xibBfIi571vbhFiMTJ3ZSu8fJziptrcYetvhZn6OOS/6Nd7TYaxaPNoH5vWRYO${NL}"
          INT_LOGO="${INT_LOGO}cKGfRdxI/cmrS7olpr4Xea7vvO7bfZn6MrJH1XMUi6L6ss/M3YKL+Gr+DFHYcsDXJe57Vz2Vc7LA${NL}"
          INT_LOGO="${INT_LOGO}feH2WpzjUF+Sc7SrUas4z04XGodZeL5UHvbktX1dKo9wk/R0MpnPRc2JMye8eRyOan8+bnL3lg4T${NL}"
          INT_LOGO="${INT_LOGO}VZOnVUJhwczZLW+qnDAnwq1v/pTM2Vd/2i3Umzw/h9rzFeTqT+50dojeDq/nnPameov/RGuhkz8f${NL}"
          INT_LOGO="${INT_LOGO}LdrGo1rNU/J0/hRFOd/rEN92KmcPL7+Zz60W0twJfz5qbQtFszw/h1rchGv+xP3y3EvpUKjd7XZm${NL}"
          INT_LOGO="${INT_LOGO}TmRPV93q1eG+Frf6ojmpa/M8P90dD0XrK8iLkE1Kl1oUlXOnyVPCrfgTredWQy3ewIFSyOT8XAqJ${NL}"
          INT_LOGO="${INT_LOGO}nDaBL0LWQV1CX/untVDv3HoOt/ZOuaO9M1ALoXyQ61t03Jtc8V4d9SdDbYd4MDkteWIutLC50Cd/${NL}"
          INT_LOGO="${INT_LOGO}4t1H9gZevFlZzGkvi3T3Vv/b3tn2po10AZSlMlapslukrQyRI1vkAUNCBCSqus00Uj6w//8vPZ4Z${NL}"
          INT_LOGO="${INT_LOGO}G7A9foHYXZI5R91sAL+AD/fOzPU4xuYlMT7o/EP3ha5kX0jftkrehEM3nsnNzve3P4/jU3WF/qTh${NL}"
          INT_LOGO="${INT_LOGO}vLR+rUTZVMF5/fdANZ7ytjiyK/Q/2XimNzv/9fL5Rcdn0nj+wxG8KH6+HhrPv67V0FP3hWR89l1V${NL}"
          INT_LOGO="${INT_LOGO}5vv3Sd/s/FNatE3K8J8/M+K8WJ1fk77Q3+o+j7KMIFOtjE/3ZfeSxGfcesbxmTae2LxQna+5vtA3${NL}"
          INT_LOGO="${INT_LOGO}dXddV5b53C9PSao9NJ56qILNS207X4/qtrIv9E3fU06dI/vyou9cn2ZblXHj+KTdvDwmr8a+0Le+${NL}"
          INT_LOGO="${INT_LOGO}KgoNZBl+J3NtYjRtPOPgxObFlhF0X0hV+tK+0MCNG0/Zt33YJZlWN55JcFLau+zG89AXutJ9IXmH${NL}"
          INT_LOGO="${INT_LOGO}wDjjPu0+xeGZGP2VluE/ceAuPNvK1vOv/XwhVeOLjX7ZxRQazx/Ugi48PLXNw0kVWbeNde5eHnZx${NL}"
          INT_LOGO="${INT_LOGO}bO7Svq0q85FoL5ivr5ky/LXU+S0pw8vQ3O0bT3kH+1+/CM2LZpo2nrFNfY7sWt3zWgz+3alU+7BL${NL}"
          INT_LOGO="${INT_LOGO}ikLy33dmklw4t1+TvpA0ep3WhYT7tNs9KJ+HVPsJme+kmPD10HpeqTL8k4rNuGMr/6lU+50JmO8k${NL}"
          INT_LOGO="${INT_LOGO}4f6RDD2v0ilD7sODCk4dn7LVpKb3ngYsi6QMr7u2DzFapY7PHwTme2P+M630XSmbEhmf3+85Nu80${NL}"
          INT_LOGO="${INT_LOGO}6d6M738+aGKVDz/GE27MCQAAAAAAAAAAAAAAAAAAAAAAAHBEEPirzWi0WYdBcBHvZ7bcbLzNZjkL${NL}"
          INT_LOGO="${INT_LOGO}kHMivhM9HzEchcalhvXM0oWXJQt4zmpZq3Ll6TeSvCtvVbfGzMvsZGNzXG6eDSyLQTF6rmd/4J3K${NL}"
          INT_LOGO="${INT_LOGO}xZyw/P2EQ8MKw7DyM+RX8a21Oao104HO2M/6BJlqhQpFYX7hyFKZYVR+xKOwQ52xn5nh/WwqVvBK${NL}"
          INT_LOGO="${INT_LOGO}W9HizuxscP2GcrrQGSf02qRZ/f3aU1zUytZzWXfAR53qzDdxwRlfgJKPMbRRZ/0BH3Wq8zmbb6OT${NL}"
          INT_LOGO="${INT_LOGO}vwAar3bLVtDg8D2vO9U5rLNSwJBvjUFtX7ZdnxhAHeg8tuM3WiFq2gGwPDg3vhQXhOtczDpGnV4J${NL}"
          INT_LOGO="${INT_LOGO}gUmn7y99/d96MywNz3yaV+9n5q+iiua8IsmEtpUPynJTbvBi1Fm7dad0Ycc8oliVSltGlWOQ48/h${NL}"
          INT_LOGO="${INT_LOGO}VWn/2KzKSwaRsTfZks5scvSN+8yGVjAsac0Ln2Npb7YdVnx0xxS4benMbGhlKuzkxyNBVDEGOfoc${NL}"
          INT_LOGO="${INT_LOGO}q8Devm2Vzt7sQK91ncfNpGdqmItvp6KTkwlqr2or9uqsq+62rrNmzFj+ZleZuPWtzbbD2mpLZzoN${NL}"
          INT_LOGO="${INT_LOGO}cmoqOuvSUkKuWTj1Q30YnOcTP3p7OqOiO+PQ6LjGMPSG+p+XCd4wtx/H1my7PuWEYtfJNqw6M1fF${NL}"
          INT_LOGO="${INT_LOGO}JldhsDfbFk5ArWa/R6dfHGCG5557jvJfA2uzramaEuliTK3OkZGwkc7AkOWXZ9ZzZoUelGfraZXS${NL}"
          INT_LOGO="${INT_LOGO}mu3QWdbprK2ol+ucmQoG5+r0CtXcmbUnsavOqESrsAOds3A9NFbUzy3nRMVqUUUByaKqrcGo37LO${NL}"
          INT_LOGO="${INT_LOGO}dfl5rDN1mjo+jrVThupmI2SnW3Wh01R4PW+w5ZkUWzZlaNbubISTda7fqNOYWC0+iR3UOfK61On1${NL}"
          INT_LOGO="${INT_LOGO}3qZzaQxEx+opQ07T+Gxdp2MW85Z+bb5LENrns+c7jeZ/tK1zVRtnJ3TlfHN3d9Ozk6Xj1Tmq1+mc${NL}"
          INT_LOGO="${INT_LOGO}oDNbVTxr3Fn2HRidOer5aB0jf1QVnm8u8q3LZ0CfpTMqKbfPLM+2x4Qbr2R2Xps68+c0wzNKrUHp${NL}"
          INT_LOGO="${INT_LOGO}OnWnZyzr7q6M2bZVnV75iKnpGZVNZrLgMWTbnFDPMNZ/s85ZxcTJmoAy5c/hqTN5LaYLnZl57lHt${NL}"
          INT_LOGO="${INT_LOGO}/kojsWEJxKqT2OGBhjrerjMonwAxrA6oqLi5TTOdz9aFX1Qc6QWd6Mw8OywvH1cXlw3x3PAqG0uy${NL}"
          INT_LOGO="${INT_LOGO}aTT7Pck2G55+afV4U1VaNkxHIdv2qjsMjqFr0sbkklVpEHrlPkPTNZ6jpjrtyLariu9w9g8U+C3q${NL}"
          INT_LOGO="${INT_LOGO}DErTYFh6pb1nPOHd2KYdU4YK566HK3Wd1zpfRti3rE3iYVijM9uBKQ9POWtJvZ38JWepnFlznVaG${NL}"
          INT_LOGO="${INT_LOGO}Z/0plUbpLajR2SvNqbOTWkLvBJ12nMRudkSiXrs616UHen3K9mv7OudO3H2/NLmY/sSrr+t1Zvaa${NL}"
          INT_LOGO="${INT_LOGO}7fKMmm9+WXup2NC+KUMN4jPsta2zYoQ5avxunNqmcW1h3bbuLxhkBqQt6cwUgLxT2vOjvxP1XHuZ${NL}"
          INT_LOGO="${INT_LOGO}dVC/yMfDbzzxqz2dy4qL/6r+CtnavAm/vimxaILmqvQAerNeJzozradTVWwv/Wo1uTbVt/S0Smhs${NL}"
          INT_LOGO="${INT_LOGO}QovXH7WmM6i8Njcw9XDXwemJ1MZsmySvkZe5RmVtGqrNnHr2CTE8POcbdnd41bin1fEcveKVbcFh${NL}"
          INT_LOGO="${INT_LOGO}/U1FQ7LZL2XXtWQAAAAAAAAAAAAAAPCBuJ1OW9rSdHrL4eyU+4E8zIN++ugm/jlIkU/N+0II91F5${NL}"
          INT_LOGO="${INT_LOGO}GOun+wv1aDBI5YzT9XvJStP9JgbT3s3gXr1258ZbGmzV7/1BsoL6ZZ4ufIeQt7EQ8ugLoY/4vZA6${NL}"
          INT_LOGO="${INT_LOGO}hXunWKhn3MV2+yiEjNCxeJTP94UrRQqxSMLXFa7+bSLuhPQ1lYsJIX/GOvXGB6J/v1244lE/SHXK${NL}"
          INT_LOGO="${INT_LOGO}X+ZC7/Bui5B2dIrJkc7BIT0KoeNS9NXPsY5G5SReKYlpkeqMLR1WTl/WOvviLvE3N+icYKJNnX0t${NL}"
          INT_LOGO="${INT_LOGO}pKBzoQ5+zKMMz1SnXkIkFqcijc5prGyhNlHUmRq/UV8FdHaq826hjnJB56NI2setfCWv8149jk0n${NL}"
          INT_LOGO="${INT_LOGO}rrax/Js0BWd1TrNPo7NbnToJFnT208OuTOaT7a3rqvYyDT1lKrWY1TlJWmd0/h6dN644dIXGkvnU${NL}"
          INT_LOGO="${INT_LOGO}rHM70PZiL+M45mTrqp/QysZie7rOhBuEtKQzzpSPqc6EO7POuFMzTb303YW0p3XqzHwr+qfr3M4V${NL}"
          INT_LOGO="${INT_LOGO}DEtb0xkf2XE22d5KQ0WdqleUeJkI3Yy6aiuPenx59DrJ9j/TGXdoCm1nqkZ3WLXO6XFL+ahMqGe2${NL}"
          INT_LOGO="${INT_LOGO}aVQn5jI6bxPXydP7qB+gsyOdsS2R1zlORotxp+d23xVa6P/t+zyJTiEWGleYBipJw7hVj+6STtVc${NL}"
          INT_LOGO="${INT_LOGO}bR+dXeiMQy2vs6daUNlPuj+UEVSHtqBzsh+KbLO6tc4b4c7V/lzdwKoO09hVO0RnJzqnRZ3T/lH+${NL}"
          INT_LOGO="${INT_LOGO}TAcq2yTeMjr3eTltRLM6VexLtPSJqx64495xz1Yg5G3cyLi4nSQjhOlEhs4kEyvT7WIxTl9OjKkl${NL}"
          INT_LOGO="${INT_LOGO}jhabzLMPJ72j1/dbny8W99NBav3mfrGYpNtNQch7+/483u37zQAAAAAAAAAAAAAAAAAAAAAAAAAA${NL}"
          INT_LOGO="${INT_LOGO}AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA${NL}"
          INT_LOGO="${INT_LOGO}AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8LH4P4CHDq0RsR4KAAAAAElF${NL}"
          INT_LOGO="${INT_LOGO}TkSuQmCC${NL}"
          
          MSG="${MSG}${INT_LOGO}${NL}"
          MSG="${MSG}${NL}"
        fi
} 



function mime_attach_file
{

#       -----------------------------------------------------------------------
#       Function to add on the mime header a file.
#       Argument : None
#
#       -----------------------------------------------------------------------

        for i in ${INT_MAIL_SECTION}
        do
          INT_START_LINE=`echo $i | awk -F"," {'print $1'}`
          INT_END_LINE=`echo $i | awk -F"," {'print $2'}`
          INT_SP_MAIL_SECTION=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
          INT_TYPE_SECTION=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /type/) print $i}'} | awk -F":" {'print $2'}`
          if [ "${INT_TYPE_SECTION}" = "attached_file" ]; then
            INT_START_LINE=$((INT_START_LINE+1))
            INT_SP_ATTACH=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP} | sed 's/BOUNDARY_KEEP/'${BOUNDARY}'/g'`
            MSG="${MSG}${INT_SP_ATTACH}${NL}${NL}"
          fi
        done
}

function mime_html_header
{
  
#       -----------------------------------------------------------------------
#       Function to define on the mime header the html body part.
#       Argument : None
#
#       -----------------------------------------------------------------------
      
        MSG="${MSG}--$BOUNDARY${NL}"
        MSG="${MSG}Content-Type: text/html${NL}"
        MSG="${MSG}Content-Transfer-Encoding: 7bit${NL}"
        MSG="${MSG}${NL}"
        MSG="${MSG}<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">${NL}"
        MSG="${MSG}${NL}"
        MSG="${MSG}<html xmlns=\"http://www.w3.org/1999/xhtml\">${NL}"
        MSG="${MSG}${NL}"
        MSG="${MSG}<head>${NL}"
        INT_COUNT=`count_specific_section title`
        if [ "${INT_COUNT}" = "1" ]; then
            HTML_TITLE=`unique_match_specific_section title`
            MSG="${MSG}<title>${HTML_TITLE}</title>${NL}"
        fi
        MSG="${MSG}${NL}" 
}   

function html_style
{
  
#       -----------------------------------------------------------------------
#       Function to add the html style on the html body.
#       Argument : None
#
#       -----------------------------------------------------------------------
  
        MSG="${MSG}<style type=\"text/css\">${NL}"
        MSG="${MSG}body {margin: 0; padding: 0; min-width: 100%!important;}${NL}"
        MSG="${MSG}body[yahoo] .class {}${NL}"
        MSG="${MSG}.content {width: 100%; max-width: 600px;}${NL}"  
        MSG="${MSG}.header {padding: 40px 30px 20px 30px;}${NL}"
        MSG="${MSG}.col425 {width: 425px!important;}${NL}"
        MSG="${MSG}.col380 {width: 380px!important;}${NL}"
        MSG="${MSG}.subhead {font-size: 15px; font-weight: bold; color: ${HTLM_HEAD_FONT_COLOR}; font-family: sans-serif; text-align: right; }${NL}"
        
        #DEBUG
        if [ "${DEBUG_EMAIL_TABLE}" = "1" ]; then
          MSG="${MSG}TABLE{border-style:solid;border-width:1px;border-color:#996;border-collapse:collapse;border-spacing:0;empty-cells:show}${NL}"
        fi
        
        MSG="${MSG}.innerpadding {padding: 30px 30px 30px 30px;}${NL}"
        MSG="${MSG}.borderbottom {border-bottom: 1px solid #f2eeed;}${NL}"
        MSG="${MSG}.h2 {padding: 0 0 15px 0; font-size: 20px; line-height: 24px; color: ${HTLM_HEAD_FONT_COLOR};font-weight: bold;}${NL}"
        MSG="${MSG}.bodycopy {font-size: 16px; line-height: 22px;}${NL}"
        MSG="${MSG}@media only screen and (min-device-width: 601px) {${NL}"
        MSG="${MSG}.content {width: 600px !important;}${NL}"
        
        MSG="${MSG}}${NL}"
        MSG="${MSG}</style>${NL}"
        MSG="${MSG}${NL}"
        MSG="${MSG}</head>${NL}"
        MSG="${MSG}${NL}"

}

function html_table_header
{
  
#       -----------------------------------------------------------------------
#       Function to define the main table on the html email part.
#       Argument : None
#
#       ----------------------------------------------------------------------- 
  
        MSG="${MSG}<body yahoo bgcolor=\"${HTML_BG_COLOR}\">${NL}"
        MSG="${MSG}<table width='100%' bgcolor='${HTML_BG_COLOR}' border='0' cellpadding='0' cellspacing='0'>${NL}"
        MSG="${MSG}<tr>${NL}"
        MSG="${MSG}<td>${NL}"
        MSG="${MSG}<!--[if (gte mso 9)|(IE)]>${NL}"
        MSG="${MSG}    <table width=\"600\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">${NL}"
        MSG="${MSG}<tr>${NL}"
        MSG="${MSG}<td>${NL}"
        MSG="${MSG}<![endif]-->${NL}"
        MSG="${MSG}<table class=\"content\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">${NL}"
        MSG="${MSG}<tr>${NL}"
        MSG="${MSG}${NL}"
}

function html_body_header
{
  
  
#       -----------------------------------------------------------------------
#       Function to define the header of the email (Title and Logo).
#       Argument : None
#
#       -----------------------------------------------------------------------   

        if [ "${LOGO}" = "1" ]; then
           INT_LOGO="<img src='cid:logo' width=\"70\" height=\"70\" border=\"0\" alt=\"\" / >"
        else
           INT_LOGO="&nbsp;" 
        fi
        INT_BODY_HEADER="
        <td class=\"header\" bgcolor=\"${HTML_HEAD_BG_COLOR}\">
        
        <table width=\"70\" align=\"left\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">
            <tr>
                <td height=\"70\" style=\"padding: 0 0 0 0;\">
                    ${INT_LOGO}
                </td>
            </tr>
        </table> 
        </td>
        <td class=\"header\" bgcolor=\"${HTML_HEAD_BG_COLOR}\">
        <!--[if (gte mso 9)|(IE)]>
        <table width=\"425\" align=\"right\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">
            <tr>
                <td height=\"70\">
                <![endif]-->
                    <table class=\"col425\" align=\"right\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" style=\"width: 100%; max-width: 425px;\">
                        <tr>
                            <td height=\"70\">
                            </td>
                            <td class=\"subhead\">
                             Unix System $HOSTNAME.
                            </td>
                        </tr>
                    </table>
                <!--[if (gte mso 9)|(IE)]>
                </td>
            </tr>
        </table>
        <![endif]-->
        </table>"   
        MSG="${MSG}${INT_BODY_HEADER}${NL}"
}

function html_body
{

#       -----------------------------------------------------------------------
#       Function to define the body of the email.
#       Here, we add all text coming from the function add_info_to_html
#       Argument : None
#
#       -----------------------------------------------------------------------   
	
        if [ "${HTML_TITLE}" != "" ]; then
          INT_HTML_TITLE="
          <table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >
                <tr >
                    <td class=\"h2\">
                        <!-- Start Title-->
                        $HTML_TITLE
                        <!-- End Title -->
                    </td>
                </tr> 
           </table>
          "
        else
          INT_HTML_TITLE=""
        fi    
        INT_BODY="
        <tr>
         <td class=\"innerpadding borderbottom\" style=\"background-color: ${HTML_BODY_BG_COLOR};\">
             ${INT_HTML_TITLE}
             <table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >     
                 <!--<tr>
                     <td class=\"bodycopy\"> -->
                         ${HTML_MESSAGE}
                     <!--</td> -->
                     <!--<td><img src='cid:ok'></td> -->
                 <!--</tr> -->
             </table>
          </td>
        </tr>"
        MSG="${MSG}${INT_BODY}${NL}"
}   

function mime_html_footer
{

#       -----------------------------------------------------------------------
#       Function to close the mime part of html.
#       Argument : None
#
#       -----------------------------------------------------------------------   	

        MSG="${MSG}${NL}"
        MSG="${MSG}--$BOUNDARY--"
}   
  
function html_table_footer
{

#       -----------------------------------------------------------------------
#       Function to close the html part of email.
#       Argument : None
#
#       -----------------------------------------------------------------------   		

        MSG="${MSG}</tr>${NL}"
        MSG="${MSG}</table>${NL}"
        MSG="${MSG}<!--[if (gte mso 9)|(IE)]>${NL}"
        MSG="${MSG}</td>${NL}"
        MSG="${MSG}</tr>${NL}"
        MSG="${MSG}</table>${NL}"
        MSG="${MSG}<![endif]-->${NL}"
        MSG="${MSG}</table>${NL}"    
}

function urlencode 
{

#       -----------------------------------------------------------------------
#       Function to encode a string as url.
#       Argument : 
#       1: The sting to encode
#
#       -----------------------------------------------------------------------   			

        old_lc_collate=$LC_COLLATE
        LC_COLLATE=C
        
        local length="${#1}"
        for (( i = 0; i < length; i++ )); do
            local c="${1:$i:1}"
            case $c in
                [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
                *) printf '%%%02X' "'$c" ;;
            esac
        done
        
        LC_COLLATE=$old_lc_collate
}

function add_file_to_mail
{

#      -----------------------------------------------------------------------
#      Function for make multi attachement
#      Arguments :
#      1 : Full path of the file to attach to the future email
#      2 : The name of file to be displayed as attached file
#      ----------------------------------------------------------------------- 

       if [ "$TEMP_ADD_FILE" = "" ]; then
         TEMP_ADD_FILE=$(mktemp  "${TEMP_DIR}/${PROGNAME}.$$.XXXXXX")
         if [ "$TEMP_ADD_FILE" = "" ]; then
           error_exit "cannot create temp file!"
         fi
       fi  
       FILE=$1
       FILE_NAME_TO_DISPLAY=$2
       echo "$FILE;$FILE_NAME_TO_DISPLAY" >> "${TEMP_ADD_FILE}"
}

function add_info_to_html
{

#       -----------------------------------------------------------------------
#       Function to add information on the mail.
#       I'm using a temporary file and add tag like <!-- #EMAIL TAG counter type:html -->
#       If later, I'm changing the way to add the information on the html part
#       I could always change only the html function (the one which add <td>text</td></tr>
#
#       Argument : 
#       1: a sting or a file
#       2: A number (0,1,2) corresponding to an icon (NOTOK,OK,WARNING)
#
#       -----------------------------------------------------------------------   		      
  
        if [ "${INT_EMAIL_TMP}" = "" ]; then
          init_email
        fi
        INT_TAG_EMAIL_COUNTER=$((INT_TAG_EMAIL_COUNTER+1))
        if [ "${2}" != "" ]; then
          echo "<!-- #EMAIL TAG ${INT_TAG_EMAIL_COUNTER} type:html img:${2} -->" >> ${INT_EMAIL_TMP}
        else
          echo "<!-- #EMAIL TAG ${INT_TAG_EMAIL_COUNTER} type:html -->" >> ${INT_EMAIL_TMP}
        fi
        if [ -f "$1" ] ; then
          cat $1 >> ${INT_EMAIL_TMP}
        else
          echo "$1" >> ${INT_EMAIL_TMP} 
        fi
}

function add_info_to_html_pre
{
	
#       -----------------------------------------------------------------------
#       Function to add information on the mail with <pre></pre>
#       Same as add_info_to_html
#
#       Argument : 
#       1: a sting or a file
#       2: A number (0,1,2) corresponding to an icon (NOTOK,OK,WARNING)
#
#       -----------------------------------------------------------------------   			      
  
        if [ "${INT_EMAIL_TMP}" = "" ]; then
          init_email
        fi
        INT_TAG_EMAIL_COUNTER=$((INT_TAG_EMAIL_COUNTER+1))
        if [ "${2}" != "" ]; then
          echo "<!-- #EMAIL TAG ${INT_TAG_EMAIL_COUNTER} type:html_pre img:${2} -->" >> ${INT_EMAIL_TMP}
        else
          echo "<!-- #EMAIL TAG ${INT_TAG_EMAIL_COUNTER} type:html_pre -->" >> ${INT_EMAIL_TMP}
        fi
        if [ -f "$1" ] ; then
          cat $1 >> ${INT_EMAIL_TMP}
        else
          echo "$1" >> ${INT_EMAIL_TMP} 
        fi
}

function add_info_to_mail
{
	
#       -----------------------------------------------------------------------
#       Function to add information on the html using the temporary file.
#       Same as add_info_to_html
#
#       Argument : None
#
#       -----------------------------------------------------------------------   				
  
        HTML_MESSAGE=""
        for i in `echo "${INT_HTML_MAIL}"`
        do
          ICON=""
          INT_START_LINE=`echo $i | awk -F"," {'print $1'}`
          INT_END_LINE=`echo $i | awk -F"," {'print $2'}`
          INT_SP_MAIL_SECTION=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
          INT_TYPE_SECTION=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /type/) print $i}'} | awk -F":" {'print $2'}`
          INT_TYPE_IMG=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /img/) print $i}'} | awk -F":" {'print $2'}`
          INT_START_LINE=$((INT_START_LINE+1))
          INT_SP_FOUND=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
          
          if [ "${INT_TYPE_IMG}" != "" ]; then
            case ${INT_TYPE_IMG} in
              "0")  ICON="<img src='cid:notok'>";
              ;;
              "1")  ICON="<img src='cid:ok'>"
              ;;
              "2")  ICON="<img src='cid:warning'>"
              ;;
            esac
          fi
          
          HTML_MESSAGE="${HTML_MESSAGE}<tr><td class=\"bodycopy\">"
          
          if [ "${INT_TYPE_SECTION}" = "html_pre" ]; then
                 HTML_MESSAGE="${HTML_MESSAGE}<pre>"
          fi
          
          HTML_MESSAGE="${HTML_MESSAGE}${NL}"
          HTML_MESSAGE="${HTML_MESSAGE}${INT_SP_FOUND}"
          
          if [ "${INT_TYPE_SECTION}" = "html_pre" ]; then
                 HTML_MESSAGE="${HTML_MESSAGE}</pre>"
          fi
          
          HTML_MESSAGE="${HTML_MESSAGE}${NL}"
          HTML_MESSAGE="${HTML_MESSAGE}</td>"
          
          if [ "${ICON}" != "" ]; then
            HTML_MESSAGE="${HTML_MESSAGE}<td align='center' width=20>$ICON</td>"
          fi  
          
          HTML_MESSAGE="${HTML_MESSAGE}</tr>${NL}"  
          
          
          
          #if [ "${INT_TYPE_SECTION}" = "html" ]; then 
          #  if [ "${INT_TYPE_IMG}" != "" ]; then
          #      case ${INT_TYPE_IMG} in
          #        "0")  ICON="<img src='cid:notok'>";
          #        ;;
          #        "1")  ICON="<img src='cid:ok'>"
          #        ;;
          #        "2")  ICON="<img src='cid:warning'>"
          #        ;;
          #      esac
          #      HTML_MESSAGE="${HTML_MESSAGE}<tr><td class=\"bodycopy\">${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}${INT_SP_FOUND}${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}</td><td align='center' width=20>$ICON</td></tr>${NL}"
          #  else
          #      HTML_MESSAGE="${HTML_MESSAGE}<tr><td class=\"bodycopy\">${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}${INT_SP_FOUND}${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}</td></tr>${NL}"
          #  fi
          #else
          #  if [ "${INT_TYPE_IMG}" != "" ]; then
          #      case ${INT_TYPE_IMG} in
          #        "0")  ICON="<img src='cid:notok'>";
          #        ;;
          #        "1")  ICON="<img src='cid:ok'>"
          #        ;;
          #        "2")  ICON="<img src='cid:warning'>"
          #        ;;
          #      esac
          #      HTML_MESSAGE="${HTML_MESSAGE}<tr><td class=\"bodycopy\"><pre>${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}${INT_SP_FOUND}${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}</pre></td><td align='center' width=20>$ICON</td></tr>${NL}"   
          #  else
          #      HTML_MESSAGE="${HTML_MESSAGE}<tr><td class=\"bodycopy\"><pre>${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}${INT_SP_FOUND}${NL}"
          #      HTML_MESSAGE="${HTML_MESSAGE}</pre></td></tr>${NL}"
          #  fi    
          #fi  
        done
}   

   

function manage_keep_email
{


#       -----------------------------------------------------------------------
#       Function called for keep the mime header always of the top of the mail
#       Not used
#       -----------------------------------------------------------------------

    TEMP_KEEP_MAIL=$(mktemp  "${TEMP_DIR}/${PROGNAME}.$$.XXXXXX")
    if [ "$TEMP_KEEP_MAIL" = "" ]; then
      error_exit "cannot create mail temp file!"
    fi
    if [ -f "${KEEP_MAIL_FILE}" ]; then
        INT_SIZE_FILE=`ls -l "${KEEP_MAIL_FILE}" | awk {'print $5'}`
        INT_SIZE_FILE=`expr $SIZE_FILE + 0`
        if [ "${INT_SIZE_FILE}" -gt 0 ]; then
          SECTION=""
          MAX_LINE=`wc -l ${KEEP_MAIL_FILE} | awk {'print $1'}`
          for i in  `awk '$0 ~ /BOUNDARY_KEEP/ {print NR}' ${KEEP_MAIL_FILE}`
          do
            if [ "${SECTION}" = "" ]; then
                  SECTION="${i}"
            else
                BEFORE=`echo "${i} -1" | bc`
                SECTION="${SECTION},${BEFORE} ${i}"
            fi
          done
        fi
        if [ "${SECTION}" != "" ]; then
            SECTION="${SECTION},${MAX_LINE}"  
            echo "${SECTION}" > ${TEMP_KEEP_MAIL}
            boundary_research
        fi
    fi
    rm -f ${TEMP_KEEP_MAIL}
}

function boundary_research
{
	
#Not used

    INT_OLD_ATTACH=""
    INT_OLD_HTML=""
    for i in `cat ${TEMP_KEEP_MAIL}`
    do
        echo $i
        INT_START_LINE=`echo $i | awk -F"," {'print $1'}`
        INT_END_LINE=`echo $i | awk -F"," {'print $2'}`
        INT_OLD_SECTION=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${KEEP_MAIL_FILE}`
        IS_ATTACHMENT=`echo "${INT_OLD_SECTION}" | egrep 'attachment|inline'`
        if [ "${IS_ATTACHMENT}" != "" ]; then
            INT_FILE_NAME_ATTACHED=`echo "${INT_OLD_SECTION}" |grep 'filename='| awk -F";" {'for(i=1; i<=NF; i++) {if( $i ~ /filename/) print $i}'}` 
            INT_ALREADY_EXIST=`echo "${INT_OLD_ATTACH}" | grep "${INT_FILE_NAME_ATTACHED}"`
            if [ "${INT_ALREADY_EXIST}" = "" ]; then
              INT_OLD_ATTACH="${INT_OLD_ATTACH}${INT_OLD_SECTION}${NL}${NL}"
            fi
        fi
        IS_BODY=`echo "${INT_OLD_SECTION}" | grep '<!-- BODY -->'`
        if [ "${IS_BODY}" != "" ]; then
            INT_OLD_HTML="${INT_OLD_HTML}${INT_OLD_SECTION}${NL}${NL}"
            OLD_LINE=`echo  "${INT_OLD_SECTION}" | wc -l | awk {'print $1'}`
            echo "OLD HTML DETECTED ${OLD_LINE}"
            INT_OLD_HTML="${INT_OLD_HTML}${INT_OLD_SECTION}${NL}${NL}"
        fi
    done  
}

function search_section
{
	
#       -----------------------------------------------------------------------
#       Function to search on the temporary file where are the section beginning
#       by the <!--.*EMAIL TAG.*-->
#
#       Argument : None
#
#       -----------------------------------------------------------------------   		
	
        INT_MAIL_SECTION=""
        INT_MAIL_MAX_LINE=`wc -l ${INT_EMAIL_TMP} | awk {'print $1'}`
        for i in `awk '{IGNORECASE=1;tmp=match($0, /^<!--.*EMAIL TAG.*-->/);if (tmp) {print NR}}' ${INT_EMAIL_TMP}`
        do
          if [ "${INT_MAIL_SECTION}" = "" ]; then
            INT_MAIL_SECTION="${i}"
          else
            INT_BEFORE=`echo "${i} -1" | bc`
            INT_MAIL_SECTION="${INT_MAIL_SECTION},${INT_BEFORE} ${i}"
          fi  
        done
        if [ "${INT_MAIL_SECTION}" = "" ]; then
            INT_MAIL_SECTION="1"
        fi
        INT_MAIL_SECTION="${INT_MAIL_SECTION},${INT_MAIL_MAX_LINE}" 
} 

function count_specific_section
{
		
#       -----------------------------------------------------------------------
#       Function to count how many specific section we found on the temporary 
#       file.
#
#       Argument : 
#       1: The type of section to search like html, html_pre ....
#
#       -----------------------------------------------------------------------   	
  
        INT_TYPE_SEARCH="${1}"
        INT_SP_FOUND="0"
        
        for i in ${INT_MAIL_SECTION}
        do
          INT_START_LINE=`echo $i | awk -F"," {'print $1'}`
          INT_END_LINE=`echo $i | awk -F"," {'print $2'}`
          INT_SP_MAIL_SECTION=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
          INT_TYPE_SECTION=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /type/) print $i}'} | awk -F":" {'print $2'}`
          if [ "${INT_TYPE_SECTION}" = "${INT_TYPE_SEARCH}" ]; then
          #if [[ "${INT_TYPE_SECTION}" =~ $INT_TYPE_SEARCH ]]; then 
            INT_SP_FOUND=$((INT_SP_FOUND+1))
          fi
        done
        echo "${INT_SP_FOUND}"
}

function unique_match_specific_section
{
  
  INT_TYPE_SEARCH="${1}"
  INT_SP_FOUND=""
  
  for i in ${INT_MAIL_SECTION}
    do
      INT_START_LINE=`echo $i | awk -F"," {'print $1'}`
      INT_END_LINE=`echo $i | awk -F"," {'print $2'}`
      INT_SP_MAIL_SECTION=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
      INT_TYPE_SECTION=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /type/) print $i}'} | awk -F":" {'print $2'}`
      if [ "${INT_TYPE_SECTION}" = "${INT_TYPE_SEARCH}" ]; then
        INT_START_LINE=$((INT_START_LINE+1))
        INT_SP_FOUND=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
      fi
    done
    echo "${INT_SP_FOUND}"
  
}

function sort_section_type_html
{
    INT_HTML_MAIL_TMP=""
    INT_HTML_MAIL=""
    for i in ${INT_MAIL_SECTION}
    do
      INT_START_LINE=`echo $i | awk -F"," {'print $1'}`
      INT_END_LINE=`echo $i | awk -F"," {'print $2'}`
      INT_SP_MAIL_SECTION=`awk NR==${INT_START_LINE},NR==${INT_END_LINE} ${INT_EMAIL_TMP}`
      INT_TYPE_SECTION=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /type/) print $i}'} | awk -F":" {'print $2'}`
      INT_TYPE_SECTION_NUMBER=`echo "${INT_SP_MAIL_SECTION}" | head -n1 | awk  {'for(i=1; i<=NF; i++) {if( $i ~ /TAG/) print $(i+1)}'}`
      if [ "${INT_TYPE_SECTION}" = "html" ]; then
        INT_HTML_MAIL_TMP="${INT_HTML_MAIL_TMP}${INT_TYPE_SECTION_NUMBER} ${i}${NL}"
      fi
      if [ "${INT_TYPE_SECTION}" = "html_pre" ]; then
        INT_HTML_MAIL_TMP="${INT_HTML_MAIL_TMP}${INT_TYPE_SECTION_NUMBER} ${i}${NL}"
      fi
    done
    INT_HTML_MAIL=`echo "${INT_HTML_MAIL_TMP}" | sed '/^$/d' | sort -nk 1 | awk {'print $NF'}`  
}   



function add_file_to_temp
{
    if [ "${TEMP_ADD_FILE}" != "" ]; then
      if [ -f "$TEMP_ADD_FILE" ]; then
        while IFS= read -r line
        do
          LFILE=`echo $line | awk -F";" {'print $1'}`
          ATTACHED_FILE_NAME=`echo $line | awk -F";" {'print $2'}`
          if [ "${ATTACHED_FILE_NAME}" = "" ]; then
            ATTACHED_FILE_NAME=`echo $LFILE | awk -F"/" {'print $NF'}`
          fi
          if [ -f "${LFILE}" ] ; then
            if [ "${BIN_FILE}" != "" ]; then
              FILE_MIME_TYPE=`${BIN_FILE} -b --mime-type $LFILE 2>/dev/null`
              if [ "${FILE_MIME_TYPE}" = "" ]; then
                FILE_MIME_TYPE="text/plain"
              fi
            else
              FILE_MIME_TYPE="text/plain"
            fi
            INT_TAG_EMAIL_COUNTER=$((INT_TAG_EMAIL_COUNTER+1))
            echo "<!-- #EMAIL TAG ${INT_TAG_EMAIL_COUNTER} type:attached_file -->" >> ${INT_EMAIL_TMP}
            INT_ATTACH=""
            INT_ATTACH="${INT_ATTACH}--BOUNDARY_KEEP${NL}"
            #INT_ATTACH="${INT_ATTACH}--$BOUNDARY${NL}"
            INT_ATTACH="${INT_ATTACH}Content-Type: ${FILE_MIME_TYPE}; name=\"${ATTACHED_FILE_NAME}\"${NL}"  
            INT_ATTACH="${INT_ATTACH}Content-Transfer-Encoding: base64${NL}"
            INT_ATTACH="${INT_ATTACH}Content-Disposition: attachment; filename=\"${ATTACHED_FILE_NAME}\"${NL}"
            INT_ATTACH="${INT_ATTACH}${NL}"
            INT_ATTACH_FILE=$( ${BIN_BASE64} -w 0 ${LFILE} )
            INT_ATTACH="${INT_ATTACH}${INT_ATTACH_FILE}${NL}"
            INT_ATTACH="${INT_ATTACH}${NL}" 
            printf '%s' "${INT_ATTACH}" >> ${INT_EMAIL_TMP}
          fi        
        done < "${TEMP_ADD_FILE}"
        rm -f ${TEMP_ADD_FILE}
        TEMP_ADD_FILE=""  
      fi
      rm -f ${TEMP_ADD_FILE} 
      TEMP_ADD_FILE=""  
    fi
    
} 

function html_email
{
    if [ "${INT_EMAIL_TMP}" = "" ]; then
      exit
    fi
    if [ "${HTML_TITLE}" != "" ]; then
      INT_TAG_EMAIL_COUNTER=$((INT_TAG_EMAIL_COUNTER+1))
      echo "<!-- #EMAIL TAG ${INT_TAG_EMAIL_COUNTER} type:title -->" >> ${INT_EMAIL_TMP}
      echo "${HTML_TITLE}" >> ${INT_EMAIL_TMP}
      HTML_TITLE=""
    fi
    add_file_to_temp
    if [ "${KEEP_MAIL}" = "1" ]; then
      cat ${INT_EMAIL_TMP} >> "${KEEP_MAIL_FILE}"
    else
      search_section
      mime_header
      mime_add_icon
      mime_attach_file
      mime_html_header
      html_style
      html_table_header
      sort_section_type_html
      add_info_to_mail
      html_body_header
      html_body
      printf '%s' "${MSG}" | sendmail -t
    fi
    rm -f ${INT_EMAIL_TMP}
    INT_EMAIL_TMP=""    
}

#        -------------------------------------------------------------------
#        Program starts here
#        -------------------------------------------------------------------


  
  
if [ ! -f "/usr/bin/which" ]; then
    echo "Please, check the binary variable for this script as which as not been found ..."
    BIN_WHICH=""
    exit 1
else
    BIN_WHICH="/usr/bin/which --skip-alias"
fi

BIN_FILE=`check_bin file`
BIN_BASE64=`check_bin base64`
BIN_SENDMAIL=`check_bin sendmail`

if [ "${TEMP_DIR}" = "" ]; then
    if [ -d ~/tmp ]; then
        TEMP_DIR=~/tmp
    else
        TEMP_DIR=/tmp
    fi
fi    

 

