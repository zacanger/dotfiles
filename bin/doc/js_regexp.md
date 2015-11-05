# Common Regular Expressions in Javascript

**Digits**
    /^[0-9]+$/

**Alphabetic Characters**
    /^[a-zA-Z]+$/

**Alpha-Numeric Characters**
    /^[a-zA-Z0-9]+$/

**Date (MM/DD/YYYY)/(MM-DD-YYYY)/(MM.DD.YYYY)/(MM DD YYYY)**
    /^(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}$/

**Email Address**
    /^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,4}$/

**Password**
The password must contain one lowercase letter, one uppercase letter, one number, one unique character such as !@\#$%^&? and be at least 6 characters long.
    /^.*(?=.{6,})(?=.*d)(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*? ]).*$/

**US Phone Numbers**
    /^(?([0-9]{3}))?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/

**US Zip code**
    /^[0-9]{5}(?:-[0-9]{4})?$/

**Slug**
    /^[a-z0-9-]+$/

**URL**
    /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/

**IP Address**
    /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/

**HTML Tag**
    /^<([a-z]+)([^<]+)*(?:>(.*)|s+/>)$/

**String trimming**
    /^s*|s*$/g

**All the special characters need to be escaped**
    /[\-\[\]\/\\\{\}\(\)\*\+\?\.\^\$\|]/


