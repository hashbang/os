#!/bin/python3

from tempfile import mkdtemp
from git import Git, Repo, cmd
from xml.etree import ElementTree
from sys import argv
from os import environ
import re

major_version="9"
platform_device=environ['DEVICE']
kernel_device=environ['KERNEL']
kind=argv[1]
kernel_manifest_url="https://android.googlesource.com/kernel/manifest"
kernel_manifest_exp="origin/android-msm-%s" % kernel_device
platform_manifest_url="https://android.googlesource.com/platform/manifest"
platform_manifest_exp="origin/android-%s" % major_version

def lsremote(url):
    remote_refs = {}
    g = cmd.Git()
    for ref in g.ls_remote(url).split('\n'):
        hash_ref_list = ref.split('\t')
        remote_refs[hash_ref_list[1]] = hash_ref_list[0]
    return remote_refs

def get_manifest(url, exp):
    repo = Repo.clone_from(url, mkdtemp())
    ref = [
        str(ref) for ref in
        sorted(repo.refs, key=lambda t: t.commit.committed_datetime)
        if re.match(exp, str(ref))
    ][-1]
    repo.head.reference = repo.commit(ref)
    string = repo.git.show('HEAD:default.xml')
    manifest = ElementTree.fromstring(string)
    revision=manifest.findall(".//default")[0].attrib['revision']
    remote_attrib=manifest.findall(".//remote")[0].attrib
    if 'review' in remote_attrib:
        remote=remote_attrib['review']
    else:
        remote=remote_attrib['fetch']
    projects=manifest.findall(".//project")

    for project in projects:
        project_repo_url="%s%s.git" % (remote, project.attrib['name'])
        remote_refs = lsremote(project_repo_url)
        if 'revision' in project.attrib:
            revision = project.attrib['revision']
        project.attrib['upstream'] = revision
        if 'refs' not in revision:
            revision = "refs/heads/%s" % revision
        project.attrib['revision'] = remote_refs[revision]

    return ElementTree.tostring(manifest, encoding='utf-8').decode()

if kind == 'kernel':
    manifest = get_manifest(kernel_manifest_url, kernel_manifest_exp)
elif kind == 'platform':
    manifest = get_manifest(platform_manifest_url, platform_manifest_exp)

print(manifest)
