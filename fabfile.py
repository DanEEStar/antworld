import os
from fabric.api import *
from fabric.contrib.project import *


def _local_path(*args):
    return os.path.join(os.path.abspath(os.path.dirname(__file__)), *args)

NAME = 'antworld'

env.use_ssh_config = True
env.user = 'root'
env.hosts = ['gurten.iterativ.ch']
env.remote_app = '/srv/www/%s' % NAME
env.local_app = _local_path('dist/')
env.rsync_exclude = []


def deploy(restart=False):
    """
    use deploy:restart=true to also restart nginx server
    """

    # FIXME: not working anymore with the new build
    sudo('mkdir -p %(remote_app)s' % env)
    rsync_project(
        remote_dir=env.remote_app,
        local_dir=env.local_app,
        exclude=env.rsync_exclude,
        extra_opts='--rsync-path="sudo rsync"'
    )

    put('nginx.conf', os.path.join('/etc/nginx/sites-enabled/%s.conf' % NAME), use_sudo=True)
    sudo("chown -R {user}:{user} {nginx_conf_file}".format(
        user='root',
        nginx_conf_file=os.path.join('/etc/nginx/sites-enabled/%s.conf' % NAME)))

    if restart:
        run('/etc/init.d/nginx restart')
