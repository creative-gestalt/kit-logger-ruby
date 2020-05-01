from . import logger
import os
from pathlib import Path
from halo import Halo

start_num = None
end_num = None


def generate_card_numbers(user, start_num, end_num):
    member_numbers = []
    path = Path('./Users/%s/ALL/extras/' % user)
    if not os.path.exists(path):
        os.makedirs(path)
    member_file = Path('./Users/%s/ALL/extras/member_numbers.txt' % user)
    start = int(start_num)
    logger.message(start)
    end = int(end_num)
    logger.message(end)
    difference = (end - start) + 1
    if difference > 101:
        message = 'Kit count exceeded 100, make sure that\'s what you intended'
        print(message)
        logger.message(message)
    for num in range(difference):
        member_numbers.append(start)
        start += 1
    with open(member_file, 'w') as m:
        for item in member_numbers:
            m.write('%s\n' % item)
    message = 'Numbers generated'
    numbers = Halo(text=message, color='cyan', text_color='cyan', spinner='Line')
    numbers.start()
    numbers.succeed()
    logger.message(message)
    return member_numbers


if __name__ == "__main__":
    generate_card_numbers(start_num, end_num)
