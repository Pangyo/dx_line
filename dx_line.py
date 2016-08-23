# -*- coding: utf-8 -*-

from bottle import Bottle, route, run, static_file, template, request, redirect, TEMPLATE_PATH
import datetime
import sys, signal
import peewee
from logging import debug, info, error
import logging
import urllib

from peewee import *

reload(sys)
sys.setdefaultencoding('utf-8')
database = SqliteDatabase('tweet.db')

class BaseModel(Model):
    class Meta:
        database = database

class User(BaseModel):
    user_id = PrimaryKeyField()
    username = CharField(unique=True)
    ip = TextField(null=True)


class Tweet(BaseModel):
    user = ForeignKeyField(User, related_name='tweets')
    message = TextField(null=False)
    created_date = DateTimeField(default=datetime.datetime.now)
    is_published = BooleanField(default=True)

    def __str__(self):
        return "[tweet] user(%d), %s, %s" % (self.user.user_id, self.message, self.created_date)


@route('/')
def main():
    return template('main')


@route('/static/<path:path>')
def callback(path):
    return static_file(path, root='/home/ubuntu/apps/dx_line/views/static')

@route('/tweet', method='GET')
def all_tweet():
    tweets = Tweet.select()
#    debug(tweets.__str__())
    return template('main', tweets=tweets)

@route('/tweet', method='POST')
def all_tweet():
    info(dir(request.body))

    message = request.body.read()
    message = urllib.unquote(message).decode('utf8')     

    first_user = User.get(User.user_id == 1)       

    new_tweet = Tweet(user_id = first_user.user_id, message = message)
    new_tweet.save()
    redirect("/tweet")

def signal_handler(signal, frame):
    print 'Signal handler called with signal', signal
    sys.exit(0)

def main():
    logging.basicConfig(level=logging.INFO)

    TEMPLATE_PATH.insert(0,'/home/ubuntu/apps/dx_line/views')

    database.connect()

    try:
        database.create_tables([User, Tweet]);
    except peewee.OperationalError as e:
        error(e)
        
    try:
        user = User.get(User.user_id == 1)
    except User.DoesNotExist:
        new_user = User(username = "first_user", ip="10.10.10.10")
        new_user.save()

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    run(host='0.0.0.0', port=80)


if __name__ == "__main__":
    main()

