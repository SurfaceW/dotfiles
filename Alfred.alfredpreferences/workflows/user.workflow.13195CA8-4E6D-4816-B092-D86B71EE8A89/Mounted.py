import os, re, glob
from Feedback import Feedback

MOUNT_FOLDER = '/Volumes'

def run():
   # Get all the mounts in Volumes
   volumes = os.listdir(MOUNT_FOLDER)

   # Get Additional Volume Information
   volume_tuples = []
   for volume_name in volumes:
      volume_arg = MOUNT_FOLDER + '/' + re.sub(' ', '\\ ', volume_name)
      extra_info = os.popen('diskutil info ' + volume_arg).read()

      # Get Partition Protocol
      volume_prot = re.search('Protocol:\s+(.+)', extra_info)
      if volume_prot:
         volume_prot = volume_prot.group(1)
         volume_icon = get_volume_icon(volume_prot)
         if volume_prot == 'SATA':
            continue
      else:
         continue

      # Get Partition Type
      volume_type = re.search('File System Personality:\s+(.+)', extra_info)
      if volume_type:
         volume_type = volume_type.group(1)
      else:
         continue

      # Get Partition Total Size
      volume_size = re.search('Total Size:\s+(\S+\s\w+)', extra_info)
      if volume_size:
         volume_size = volume_size.group(1)
      else:
         continue

      # Append Values to tuple if all fields present
      subtitle = 'Protocol: ' + volume_prot + '   |   ' + 'Type: ' + \
                 volume_type + '   |   ' + 'Size: ' + volume_size
      volume_tuples.append((volume_name, subtitle, volume_arg, volume_icon))

   # Create the object to display mounts
   feedback = Feedback()

   # Add the mount items
   for volume_name, subtitle, volume_arg, volume_icon in volume_tuples:
      # feedback.add_item(volume_name)
      feedback.add_item(volume_name, subtitle, volume_arg, icon=volume_icon)

   if  volume_tuples:
      feedback.add_item('All', 'Eject All Disks.', 'all')
   # If no volumes are mounted...say so
   else:
      feedback.add_item('No Volumes Found...', 'Searched for mounted drives in /Volumes')

   return feedback

def get_volume_icon(protocol):
   if protocol == 'USB':
      return 'USB.png'
   elif protocol == 'Disk Image':
      return 'DMG.png'
   elif protocol == 'FireWire':
      return 'FireWire.png'
   elif protocol == 'Secure Digital':
      return 'SD.png'
   else:
      return 'icon.png'