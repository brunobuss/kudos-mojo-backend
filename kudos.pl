package Model;
use strict;
use ORLite {
    file    => 'kudos.db',
    unicode => 1,
    create  => sub {
        my $dbh = shift;
        $dbh->do(q{
            CREATE TABLE kudos (
            	id INTEGER PRIMARY KEY,         
            	person TEXT NOT NULL, 
            	reason TEXT NOT NULL,
            	date   TEXT NOT NULL
            )}
        );
 
        $dbh->do(q{
            CREATE TABLE users (
            	id INTEGER PRIMARY KEY,         
            	name TEXT NOT NULL
            )}
        );

        $dbh->do(q{
        	INSERT INTO users (name)
         	VALUES 	('Bruno C. Buss'), 
         			('Sir Arthur'),
         			('Luke Skywalker')
            }
        );

        # just use $dbh->do(...) if you need more
        # tables
        return 1;
      }
};
     
package main;
use Mojolicious::Lite;
use Mojo::JSON;

get '/kudos' => sub {
	my $self = shift;

	my $content = [ map {
			{
				person => $_->{person},
				reason => $_->{reason},
				date   => $_->{date},
			}
		} Model::Kudos->select('ORDER BY id DESC LIMIT 100') ];

	$self->render( json => $content );
};

post '/kudos' => sub {
	my $self = shift;

	my $content = $self->tx->req->content->get_body_chunk(0);
	my $new_kudo = Mojo::JSON->new->decode( $content );

	Model::Kudos->create( %$new_kudo );

	$self->render( json => $content );
};

options '/kudos' => sub {
	my $self = shift;

	$self->render( json => [ 'GET', 'POST' ] );
};

get '/users' => sub {
	my $self = shift;

	my $content = [ map { $_->{name} } Model::Users->select('ORDER BY name') ];
	$self->render( json => $content );
};

options '/users' => sub {
	my $self = shift;

	$self->render( json => [ 'GET' ] );
};

app->start;
