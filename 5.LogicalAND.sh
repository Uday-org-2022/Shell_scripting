read -p "Enter the Age : " age

if [ $age -gt 18 ] && [ $age -lt 50 ]
then
echo "Valid Age"
else
echo "Not  Valid Age"
fi
