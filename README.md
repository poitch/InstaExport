# InstaExport

A quick utility to export your own Instagram photos into a zip file.

# How it works

## Create an Instagram Application

You first need to create a new application for instagram on their website.

http://instagram.com/developer/client/register/

You really need to use http://localhost:4567/oauth/callback as the OAuth redirect_uri

## Edit the configuration file

Add the client_id and client_secret in ~/.instaexport.yaml

## Install dependencies

    bundle install

## Run the application

    ruby instaexport.rb

## Export

Visit localhost:4567, it will ask you to connect to Instagram, you authorize the application obviously. It will then redirect you to InstaExport. If everything goes well you should see your current photos and a link to export.

The export link will take a while to complete, it will download all images and generate a zip file.
