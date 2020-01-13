#Expects one argument which is a path to a template file
if [ "$1" == "" ]; then
	(>&2 echo "Missing argument \"template\".";)
	exit 1;
fi

#Test for template file
if [ ! -f "$1" ]; then
	(>&2 echo "Template file \"${1}\" is not present.";)
	exit 1;
fi

ln -s "$(dirname $0)/execute.sh" $(basename $1 | sed 's;.txt$;.sh;');
