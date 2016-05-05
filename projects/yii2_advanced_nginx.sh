#!/bin/bash

while [[ -z $app_front_url ]]
do
    read -p "Enter frontend url: " app_front_url
done

while [[ -z $app_back_url ]]
do
    read -e -p "Enter backend url: " -i "admin."$app_front_url  app_back_url
done

while [[ -z $app_path ]]
do
    read -e -p "Enter path to your web application: " -i "/var/www/"$app_front_url app_path
done

while [[ -z $access_front_file ]]
do
    read -e -p "Name for frontend access log file: " -i "/var/log/nginx/"$app_front_url".access.log" access_front_file
done

while [[ -z $error_front_file ]]
do
    read -e -p "Name for frontend error log file: " -i "/var/log/nginx/"$app_front_url".error.log" error_front_file
done

while [[ -z $access_back_file ]]
do
    read -e -p "Name for backend access log file: " -i "/var/log/nginx/"$app_back_url".access.log" access_back_file
done

while [[ -z $error_back_file ]]
do
    read -e -p "Name for backend error log file: " -i "/var/log/nginx/"$app_back_url".error.log" error_back_file
done

while [[ -z $template ]]
do
    read -e -p "Name of config's template: " -i $PWD"/template.tpl" template
done

while [[ -z $file_config ]]
do
    read -e -p "Name for config nginx: " -i "/etc/nginx/sites-available/"$app_front_url".conf" file_config
done

echo "Generate nginx config..."

declare -A app_params_front
declare -A app_params_back
app_params_front=([APP_URL]=$app_front_url [APP_PATH]=$app_path"/frontend" [APP_ACCESS]=$access_front_file [APP_ERROR]=$error_front_file )
app_params_back=([APP_URL]=$app_back_url [APP_PATH]=$app_path"/backend" [APP_ACCESS]=$access_back_file [APP_ERROR]=$error_back_file )

conf_text=$(< $template);

frontend_text=$conf_text
backend_text=$conf_text

for i in "${!app_params_front[@]}"
do
    frontend_text=${frontend_text//"{{"$i"}}"/${app_params_front[$i]}}
done

for i in "${!app_params_back[@]}"
do
    backend_text=${backend_text//"{{"$i"}}"/${app_params_back[$i]}}
done


echo "Save nginx config..."


if [ -f $file_config ];
then
    while [[ $owerwrite_config_file != "y" && $owerwrite_config_file != "n" ]]
    do
        read -p "File $file_config has been exist! Owerwrite? (y/n) " owerwrite_config_file
    done
    if [ $owerwrite_config_file != "y" ];
    then
        exit 0;
    fi
fi

echo "$frontend_text"$'\n'"$backend_text" > $file_config

while [[ $generate_symlink != "y" && $generate_symlink != "n" ]]
do
    read -p "Generate symlink (for sited-enabled path)? (y/n) " generate_symlink
done
if [[ $generate_symlink == 'y' ]];
then
    while [[ -z $symlink_path ]]
    do
        read -e -p "Name for symlink config nginx (for sited-enabled): " -i "/etc/nginx/sites-enabled/"$app_front_url".conf" symlink_path
    done
    echo "Create simlink in nginx sites-enabled path..."
    echo "$file_config $symlink_path"
    ln -s "$file_config" "$symlink_path"
fi

echo "Nginx config files has been created!"

while [[ $add_to_hosts != "y" && $add_to_hosts != "n" ]]
do
    read -p "Add to hosts? (y/n): " add_to_hosts
done


if [[ $add_to_hosts == 'y' ]];
then
    while [[ -z $hosts_path ]]
    do
        read -e -p "Path to hosts-file: " -i "/etc/hosts" hosts_path
    done
    while [[ -z $ip_address ]]
    do
        read -e -p "IP-address: " -i "127.0.0.1" ip_address
    done

    echo "Add new lines in hosts-file..."
    echo "$ip_address $app_front_url" >> $hosts_path
    echo "$ip_address $app_back_url" >> $hosts_path
fi

while  [[ $reload_nginx != "y" && $reload_nginx != "n" ]]
do
    read -p "Reload nginx?(y/n) " reload_nginx
done

if [[ $reload_nginx == 'y' ]];
then
    service nginx reload;
fi

echo "Complete!"