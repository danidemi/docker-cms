Build an image that allows to run a playground version of Wordpress.

The long term goal is to provide access to all major Content Management Systems, 
even though just Wordpress is currently supported. 

The Docker image being built is not currently intended to run in production,
it just allows you to play around with CMSs and allows you to choose which CMS you prefer.

Build with

	$ docker build --tag="cms:0.1" .

Then run a container with 

	$ docker run -p 10100:10100 -p 10101:10101 -p 80:80 -p 21:21 --rm cms:0.1

Connect to 

	http://127.0.0.1/wordpress

To start playing around.

## FTP

The container provides FTP access, in order to let you install
Wordpress plugins from within the admin console.
Username is `cms`, password is `cms`. 
