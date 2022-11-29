path='/etc/asterisk'

read -p "Enter username: " user
read -p "Enter password: " pass

ext=100

isInFile=$(cat pjsip.conf | grep -c $user)

for (( i=1 ; i>0; i++))
do
	count=$(cat extensions.conf | grep -c $ext)

	if [ $count -ne 0 ]; then
		((ext++))
		echo New extension added...
	else
		echo ...
		echo No extension added...
		break
	fi
done

if [ $isInFile -eq 0 ]; then
        echo New User Added...
	echo ...
	echo Username: $user
	echo Password: $pass
        echo Extension: $ext
	echo -e "
[$user]
type = aor
max_contacts = 2

[${user}auth]
type = auth
username = $user
password = $pass

[$user]
type = endpoint
context = phones
allow = ulaw
auth = ${user}auth
outbound_auth = $user
aors = $user
" >> pjsip.conf
	echo -e "
exten => ${ext},1,NoOp(First Line)
same => n,NoOp(Second Line)
same => n,Dial(pjsip/${user})
same => n,Hangup
" >> extensions.conf
else
        echo This user already exists
fi

systemctl restart asterisk
