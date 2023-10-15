---
title: 工具-删除hexo中未引用的图片
categories:
  - Code & Program
date: 2023-06-20 09:41:57
tags:
cover:
---

## Before

博客由wordpress迁移而来，有很多不是用的图片资源，现在来删除一下．

## 删除没有引用的文件&&统一文件名

```py
import os
import re
import uuid

post_dir = "source/_posts/"
image_dir = "source/images/"


def get_ref_filename(root_dir):
	referenced_files = set()

	for dirpath, _, filenames in os.walk(root_dir):
		for filename in filenames:
			if filename.endswith(".md"):
				file_path = os.path.join(dirpath, filename)
				with open(file_path, "r") as file:
					contents = file.read()
					matches = re.findall(r"images\/(.+\..+)\)", contents)
					referenced_files.update(matches)

	return referenced_files


def get_source_filenames(directory):
	picture_files = []
	valid_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp']

	for filename in os.listdir(directory):
		file_extension = os.path.splitext(filename)[1].lower()
		if file_extension in valid_extensions:
			picture_files.append(filename)

	return set(picture_files)


def del_unref_files():
	referenced_files = get_ref_filename(post_dir)
	pic_files = get_source_filenames(image_dir)
	unref_file = list(pic_files - referenced_files)
	print(unref_file)

	for e in unref_file:
		try:
			os.remove(image_dir + e)
			print(f"Deleted file: {e}")
		except OSError as e:
			print(f"Error deleting file: {e} - {e}")


def rename_ref_in_post(oldname, newname):
	for dirpath, _, filenames in os.walk(post_dir):
		for filename in filenames:
			if filename.endswith(".md"):
				file_path = os.path.join(dirpath, filename)
				with open(file_path, "r+") as file:
					contents = file.read()

					contents = contents.replace(oldname, newname)

					file.seek(0)
					file.truncate()
					file.write(contents)


def random_filename(post_dir, image_dir):
	fms = get_ref_filename(post_dir)
	for fm in fms:
		suffix = fm.split(".")[-1]
		uid = str(uuid.uuid4())[:6]
		os.rename(f"{image_dir}{fm}", f"{image_dir}{uid}.{suffix}")
		rename_ref_in_post(fm, f"{uid}.{suffix}")

if __name__ == '__main__':
	# rename_ref_in_post('image-5-1024x691.png', 'image-5.png')
	random_filename(post_dir, image_dir)
```
