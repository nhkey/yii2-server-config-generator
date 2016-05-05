#!/bin/bash

while [[ -z $app_url ]]
do
    read -p "Enter url: " app_url
done

while [[ -z $app_path ]]
do
    read -e -p "Enter path to your web application: " -i "/var/www/"$app_url app_path
done

while [[ -z $access_file ]]
do
    read -e -p "Name for access log file: " -i "/var/log/nginx/"$app_url".access.log" access_file
done

while [[ -z $error_file ]]
do
    read -e -p "Name for error log file: " -i "/var/log/nginx/"$app_url".error.log" error_file
done

while [[ -z $template ]]
do
    read -e -p "Name of config's template: " -i $PWD"/template.tpl" template
done

while [[ -z $file_config ]]
do
    read -e -p "Name for config nginx: " -i "/etc/nginx/sites-available/"$app_url".conf" file_config
done

echo "Generate nginx config..."

declare -A app_params
app_params=([APP_URL]=$app_url [APP_PATH]=$app_path [APP_ACCESS]=$access_file [APP_ERROR]=$error_file )

conf_text=$(< $template);

for i in "${!app_params[@]}"
do
    conf_text=${conf_text//"{{"$i"}}"/${app_params[$i]}}
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

echo "$conf_text" > $file_config

while [[ $generate_symlink != "y" && $generate_symlink != "n" ]]
do
    read -p "Generate symlink (for sited-enabled path)? (y/n) " generate_symlink
done
if [[ $generate_symlink == 'y' ]];
then
    while [[ -z $symlink_path ]]
    do
        read -e -p "Name for symlink config nginx (for sited-enabled): " -i "/etc/nginx/sites-enabled/"$app_url".conf" symlink_path
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
    echo "$ip_address $app_url" >> $hosts_path
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