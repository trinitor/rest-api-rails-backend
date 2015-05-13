rm db/test*.sqlite3
rake db:migrate RAILS_ENV=test
rake db:migrate RAILS_ENV=test_masterdata
sqlite3 db/test.sqlite3 "drop table users;"
sqlite3 db/test.sqlite3 "drop table friendships;"
sqlite3 db/test.sqlite3 "drop table friendrequests;"
sqlite3 db/test.sqlite3 "drop table devices;"
sqlite3 db/test_masterdata.sqlite3 "drop table data_resource;"

rm db/development*.sqlite3
rake db:migrate RAILS_ENV=development
rake db:migrate RAILS_ENV=development_masterdata
rake db:fixtures:load RAILS_ENV=development
sqlite3 db/development.sqlite3 "drop table users;"
sqlite3 db/development.sqlite3 "drop table friendships;"
sqlite3 db/development.sqlite3 "drop table friendrequests;"
sqlite3 db/development.sqlite3 "drop table devices;"
sqlite3 db/development_masterdata.sqlite3 "drop table data_resource;"

rails c < scripts/configure_push_development
