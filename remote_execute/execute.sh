#Set up the base directory of the executable file
#See https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done

# Check for sed option
# per https://github.com/danielebailo/couchdb-dump/pull/38/files
if [ "`uname -s`" = "Darwin" ]; then
    sed_regexp_option='E'
else
    sed_regexp_option='r'
fi

templateDir="$(dirname $SOURCE)/templates/";

#if the filename is not execute, this is being started by a symbolic link
#use the link's name for the template name
name=$(basename $0 | cut -d. -f1);
if [ $name != "execute" ]; then
	_TEMPLATE="${templateDir}${name}.txt"
fi

#Loop over key=value arguments
for var in "$@"
do
	#echo "$var";
	if [ "$(echo $var | cut -d'=' -f2)" != "" ]; then
		declare -x "_$(echo $var | cut -d'=' -f1 | tr [:lower:] [:upper:])"="$(echo $var | cut -d'=' -f2)" 
		subVarLst+="\$_$(echo $var | cut -d'=' -f1 | tr [:lower:] [:upper:]),"
	fi
done

#Test for template variable
if [ "$_TEMPLATE" == "" ]; then
	(>&2 echo "Missing argument \"template\".";)
	exit 1;
fi

#Test for host variable
if [ "$_HOST" == "" ]; then
	(>&2 echo "Missing argument \"host\".";)
	exit 1;
fi

#Test for template file
if [ ! -f "$_TEMPLATE" ]; then
	(>&2 echo "Template file \"${_TEMPLATE}\" is not present.";)
	exit 1;
fi

#Put template's variables in an array
declare -a templateVariables=($(grep '\$' $_TEMPLATE | sed -${sed_regexp_option}e 's;\$\{*;\n;g' | grep '^_' | sed -e 's;^\([_a-zA-Z0-9]\+\).*$;\1;' | sort -u))


missing="";
declare -a missingArray;
dlm="";

#Check for variables in the template that are not set
for i in "${templateVariables[@]}";
do
	#echo "$i: ${!i}";
	if [ "${!i}" == "" ]; then 
		missing+=$dlm$i;dlm=", "; 
		missingArray+=("$i");
	fi
done

#If anything is missing, alert the user and quit
if [ "$missing" != "" ]; then
	(>&2 echo "Missing arguments (format name=value): $(echo $missing | tr -d "_")";)
	for i in "${missingArray[@]}"; do 
		(>&2 grep '^# '$i $_TEMPLATE;)
	done
	exit 1;
fi

remote="ssh ${_HOST}"
${remote} 2> /dev/null < <(envsubst $subVarLst <$_TEMPLATE)

exit $?
