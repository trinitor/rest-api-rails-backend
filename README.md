# About

Json REST API backend template  
I've started with rails only recently. Suggestions are very welcome.  
A working frontend can be found here: https://github.com/trinitor/rest-api-ios-frontend

## Features
- token based authentication
- create user accounts
- create friendships (two way)
- encrypted passwords in database
- push notifications for iOS devices
- send emails
- multiple databases

## Resources
- Users   => Api::V1::UsersController  
- Devices   => Api::V1::DevicesController  
- Friends   => Api::V1::FriendsController  
- Friendrequests   => Api::V1::FriendrequestsController

## GEMs
- [rails-api](https://github.com/rails-api/rails-api)
- [rails_admin](https://github.com/sferik/rails_admin)
- [dotenv-rails](https://github.com/bkeepers/dotenv)
- [rpush](https://github.com/rpush/rpush)

## Installation
cp conf/database.yml.example conf/database.yml  
edit conf/database.yml  
-> configure database settings

cp .env.example .env  
edit .env  
-> set username and password for the admin interface

vi conf/secrets.yml  
-> change the development and test secret keys if required

gem update  
bundle install  
rake test  
scripts/init\_dev\_test\_environment.sh

rails s --binding=0.0.0.0

## Configuration
### change project name
grep -l -r myproject *  
edit all found files and replace myproject with the new name

grep -r example.com  
edit all found files and replace example.com with the new URL

### push notifications
create your push certificate and put it into config/certs/  
edit scripts/configure\_push\_iOS and run it (inital configuration)  
rpush start

### email settings
edit the following files:  
app/mailers/application\_mailer.rb  
app/mailers/default\_mailer.rb  
app/views/default\_mailer/user\_email\_welcome.html.erb  
app/views/default\_mailer/user\_email\_welcome.text.erb

### multiple databases
Your can run multiple instances and share the masterdata between them.  
For example you could have different worlds of a game, but have always the same login.  
It is as well possible to separate database access. Admin user can change only the game date, but not the personal user data.

In this example project there is a masterdata db and the regular db in the database.yml file  
Inside the model file you can specify the Masterdate relation with "class User < Masterdata" vs. "class Gamedata < ActiveRecord::Base"

### admin interface
The admin interface is based on rails\_admin https://github.com/sferik/rails\_admin  

Username and password a set though an environment variable (.env file in development or inside the apache configuration in production)  
The URL is http://servername:3000/admin

## API Documentation
### API V1
* based on jsonapi.org  
  send format => { resource : { value1, value2, ...} }  
  receive format one item => { resources : [{ value1, value2, ...}] }  
  receive format multiple items => { resources : [{ value1, value2, ...},{ value1, value2, ...}] }
* each responds has a message key, but it should only be used for debugging

#### root
    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc1" http://localhost:3000/api/v1
    {
      "name":"api server",
      "version":"v1",
      "title":"myproject",
      "description":"json api for myproject",
      "protocol":"rest",
      "rootUrl":"http://api.example.com/.",
      "servicePath":"/api/v1/.",
      "resources":[]
    }

#### user
login:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -X GET -d '{ "user" : {"name":"user01", "password":"123456"}}' http://localhost:3000/api/v1/users/login
    {
      "user":
        [
          {
            "id":21637642,
            "name":"user01",
            "auth_token":"abc1",
            "href":"http://localhost:3000/api/v1/users/21637642"
          }
        ],
      "message":"successful login"
    }

create:  

    curl -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{ "user" : {"name":"user99", "password":"abc1abc4", "password_confirmation":"abc1abc4"}}' http://localhost:3000/api/v1/users
    {
      "user":
        [
          {
            "id":824237707,
            "name":"user99",
            "auth_token":"abcdefg_123",
            "href":"http://localhost:3000/api/v1/users/824237707"
          }
        ],
      "message":"user created"
    }

view:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc1" -X GET http://localhost:3000/api/v1/users/21637642
    {
      "user":
        [
          {
            "name":"user01",
            "token":"abc1"
          }
        ],
      "message":"view user"
    }

#### devices
show all:  

    > curl -H "Accept: application/json" -H "Authorization: Token token=abc1" http://localhost:3000/api/v1/users/21637642/devices
    {
      "devices":
        [
          {"id":136888436,"OS":"iOS","push_token":"pushabc1","href":"http://localhost:3000/api/v1/users/21637642/devices/136888436"},
          {"id":287412680,"OS":"iOS","push_token":"pushabc2","href":"http://localhost:3000/api/v1/users/21637642/devices/287412680"},
          {"id":640065887,"OS":"iOS","push_token":"pushabc3","href":"http://localhost:3000/api/v1/users/21637642/devices/640065887"}
        ],
      "message":"show all devices for one user"
    }

show one:  

    > curl -H "Accept: application/json" -H "Authorization: Token token=abc1" http://localhost:3000/api/v1/users/21637642/devices/136888436
    {
      "devices":
        [
          {
            "id":136888436,
            "OS":"iOS",
            "push_token":"pushabc1",
            "href":"http://localhost:3000/api/v1/users/21637642"
          }
        ],
      "message":"show device"
    }

create:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc1" -X POST -d '{"device":{"user_id":"21637642","os":"iOS","push_token":"abc4"}}' http://localhost:3000/api/v1/users/21637642/devices/
    {
      "device":
        [
          {
            "id":640065888,
            "OS":"iOS",
            "push_token":"abc4",
            "href":"http://localhost:3000/api/v1/users/21637642/devices/640065888"
          }
        ],
      "message":"device created"
    }

update:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc1" -X PATCH -d '{"device":{"user_id":"21637642","os":"iOS","push_token":"abc4foo"}}' http://localhost:3000/api/v1/users/21637642/devices/640065888
    {
      "device":
        [
          {
            "id":640065888,
            "OS":"iOS",
            "push_token":"abc4foo",
            "href":"http://localhost:3000/api/v1/users/21637642/devices/640065888"
          }
        ],
        "message":"device updated"
      }

delete:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc1" -X DELETE http://localhost:3000/api/v1/users/21637642/devices/640065888
    {
      "devices":
        [
          {"status":0}
        ],
      "message":"device removed"
    }

#### friends
show all:  

    > curl -H "Accept: application/json" -H "Authorization: Token token=abc1" http://localhost:3000/api/v1/users/21637642/friends
    {
      "friends":
        [
          {"friend_id":407075762,"friend_name":"user02","status":2,"href":"http://localhost:3000/api/v1/users/407075762"}
        ],
      "message":"show all confirmed friends for one user"
    }

show one:  

    > curl -H "Accept: application/json" -H "Authorization: Token token=abc1" http://localhost:3000/api/v1/users/21637642/friends/user02
    {
      "friends":
        [
          {
            "friend_id":407075762,
            "friend_name":"user02",
            "status":2,
            "href":"http://localhost:3000/api/v1/users/407075762"
          }
        ]
      }

delete:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc1" -X DELETE http://localhost:3000/api/v1/users/21637642/friends/user02
    {
      "friendship":
        [
          {"status":0}
        ],
      "message":"friendship removed"
    }

#### friendrequest
show open requests:  

    > curl -H "Accept: application/json" -H "Authorization: Token token=abc1" http://localhost:3000/api/v1/users/21637642/friendrequests?status=open_requests
    {
      "friendrequests":
        [
          {"friend_id":793004837,"friend_name":"user03","status":1,"href":"http://localhost:3000/api/v1/users/793004837"}
        ],
      "message":"show all open requests for one user"
    }

show pending friends:  

    > curl -H "Accept: application/json" -H "Authorization: Token token=abc3" http://localhost:3000/api/v1/users/793004837/friendrequests?status=pending
    {
      "friendrequests":
        [
          {"friend_id":21637642,"friend_name":"user01","status":1,"href":"http://localhost:3000/api/v1/users/21637642"}
        ],
      "message":"show all pending users for one user"
    }

create request:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc1" -X POST -d '' http://localhost:3000/api/v1/users/21637642/friendrequests/user04
    {
      "friendrequests":
        [
          {"user":"user01","friend":"user04","status":1,"href":"http://localhost:3000/api/v1/users/21637642/friendrequests/838347756"}
        ],
      "message":"request created"
    }

create response:  

    > curl -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: Token token=abc4" -X PATCH -d '{ "friendrequest": {"action":"2"}}' http://localhost:3000/api/v1/users/824237706/friendrequests/user01
    {
      "friendships":
        [
          {
            "friend":"user01",
            "status":2,
            "href":"http://localhost:3000/api/v1/users/824237706/friends/21637642"
          }
        ],
      "message":"response created"
    }

## Apache2.4/Passenger configuration
    <VirtualHost *:443>
      ServerName api.example.com
      DocumentRoot /data/rails/myprojectname/public
    
      RailsEnv production
    
      SetEnv SECRET_KEY_BASE abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
      SetEnv email_smtp smtp.example.com
      SetEnv email_user user@example.com
      SetEnv email_pass abcdef1234567890
    
      PassengerMaxPoolSize 4
    
      <Directory /data/rails/myprojectname/public>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
      </Directory>
    
      LogLevel info
      ErrorLog /var/log/apache2/myprojectname-error.log
      CustomLog /var/log/apache2/myprojectname-access.log combined
    
      SSLEngine on
      SSLOptions +StrictRequire
      SSLCertificateFile /etc/ssl/certs/api_example.com.crt
      SSLCertificateKeyFile /etc/ssl/certs/api_example.com.key
    </VirtualHost>

