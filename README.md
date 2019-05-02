# Remote Script Templates

I run lots of scripts on lots of servers. This bash script makes it easier with templating. Maybe it will help you too.

The main script is execute.sh. It requires two arguments: host=\<hostname\> template=\<template filename\>. It runs the template on the remote host. Very simple, very easy especially if you have ssh keys and config set up. So from the remote\_execute directory "./execute.sh host=myHost template=templates/hostname.txt" returns a string of \<hostname\>^\<external ip address\>.

The next helpful thing is having variables in the templates. That enables this command "./execute.sh host=myHost template=templates/id.txt user=myUser" to return the result of the id command for myUser on myHost.

The script doesn't have any logging/etc on purpose. It does return the last status code of the remotely executed command, so "./execute.sh host=myHost template=templates/id.txt user=nonExistingUser; echo $?" will output "1" because the id command failed.

Typing "template=blahblahblah" over and over isn't any fun, so if you make a symbolic link to execute.sh with the same name as a template, then it will run execute.sh with that template.

Typing ln -s blahblahblah is a pain because I never remember if target or source goes first. Thus there is a makeLink.sh script that takes one argument, the path to the template. It'll make sure the template file is in place and then make the symbolic link for you. makeLink.sh makes the link wherever you are, so if you are in /usr/local/scripts/ and run "/path/to/remote\_execute/makeLink.sh /path/to/remote\_execute/templates/id.txt" then you get a link named id.sh that you can run from there instead of the remote\_execute directory.

What if I forget to include a variable? Great question: execute.sh scans the template file and makes sure there is a variables from the arguments that matches every variable referenced in the template. The variables referenced in the template have names which are all caps led by an underscore. So id.txt looks like id "\$_USER" (curly brackets around the variables are optional). If you include a comment, then you can output an explanation of the variable, like "\# \_USER An account identifier. The variables to replace are identified by that underscore-uppercase format so don't use that format for variables to be used on the remote host. Check out template groups.txt for an example of a script that includes a variable we replace and another we don't.

What if I want an optional variable in my template? Great question: I havn't gotten to that yet. Fork away or send me an approach.
