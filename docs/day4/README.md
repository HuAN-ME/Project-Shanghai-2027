#Day 4
Today I've learned that User/Group and those permissions

'id' which shows uid/gid and groups, uid means UserID, gid means GroupID(main group),groups shows what user belong
'groups' means that Permission base, there were not just one user in a group, also not one group in such a user
'useradd' add new user to maintain system, such as "sudo useradd newone"
'userdel' delete user from system, such as "sudo userdel somebody"
'passwd' use to set password by users, its a convinient way to adjust users permission
'groupadd' add new group to groups list, such as "sudo groupadd newgroup"
'usermod' take user to destination group, also contains original group
'su' gets change user, such as "su - userthatway"

when we take that command "cat /etc/passwd | tail"
we would see that details of user's name/uid/gid/descriptions/home directory/shell

sudo usermod -aG docker somebody
add a user to groups will be a normally action in routine operation

also, we can "grep group /etc/group" to check who living in the group then gets konw how to sprate permissions
 
