# -*- coding: utf-8 -*-

from bottle import Bottle, route, run, static_file, template, request, redirect, TEMPLATE_PATH
import datetime
import sys, signal
import peewee
from playhouse.shortcuts import *
from logging import debug, info, error
import logging
import urllib
import pusher
import json

from peewee import *

reload(sys)
sys.setdefaultencoding('utf-8')
database = SqliteDatabase('tweet.db')

def default(obj):
    """Default JSON serializer."""
    import calendar, datetime

    if isinstance(obj, datetime.datetime):
        if obj.utcoffset() is not None:
            obj = obj - obj.utcoffset()
        millis = int(
            calendar.timegm(obj.timetuple()) * 1000 +
            obj.microsecond / 1000
        )
        return millis
    raise TypeError('Not sure how to serialize %s' % (obj,))

class BaseModel(Model):
    class Meta:
        database = database

class User(BaseModel):
    user_id = PrimaryKeyField()
    username = CharField(unique=False)
    ip = TextField(null=True)

    class Meta:
        database = database

class Tweet(BaseModel):
    seq = PrimaryKeyField()
    user = ForeignKeyField(User, related_name='tweets')
    message = TextField(null=False)
    created_date = DateTimeField(default=datetime.datetime.now())
    is_published = BooleanField(default=True)

    def to_dict(self, key_map=None):
        dic = model_to_dict(self)

        if key_map is None:
            return dic

        mapped_dic = {}
        for k in dic.keys():
            # auto generated & useless value
            if k == 'id':
                continue
            mapped_dic[key_map[k]] = dic[k]
        return mapped_dic

    def __str__(self):
        return "[tweet] user(%d), %s, %s" % (self.user.user_id, self.message, self.created_date)

def lst_to_dict(model_lst):
    mapped_dic_lst = []
    for m in model_lst:
        mapped_dic_lst.append(m.to_dict())
    return mapped_dic_lst

@route('/static/<path:path>')
def callback(path):
    return static_file(path, root='/home/ubuntu/apps/dx_line/views/static')

@route('/', method='GET')
def main_page():
    return template('main')

@route('/tweet', method='GET')
def all_tweet():
    tweets = Tweet.select()

    json_tweets = json.dumps(lst_to_dict(tweets), default=default)
#    info(json_tweets)
    
    ajax_response = {}
    ajax_response['isSuccessful'] = 'success'
    ajax_response['tweets'] = json_tweets

    return ajax_response


@route('/tweet', method='POST')
def post_tweet():
#    message = request.body.read()
#    message = urllib.unquote(message).decode('utf8')     
    message = request.forms.get('message')

    client_ip = request.environ.get('REMOTE_ADDR')
    user, created = User.create_or_get(username="user", ip=client_ip)    

    new_tweet = Tweet(user_id = user.user_id, message = message)
    new_tweet.save()

    tweets = Tweet.select()

    pusher_client = pusher.Pusher(
      app_id='240396',
      key='37bb3952bcef157d7b44',
      secret='80b507b0d12021f3b963',
      ssl=True
    )

    pusher_client.trigger('tweet', 'post_tweet', all_tweet())

    return all_tweet()

#    redirect("/tweet")

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
        
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    run(host='0.0.0.0', port=80)


if __name__ == "__main__":
    main()

