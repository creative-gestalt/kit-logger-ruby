from telegram.ext import (Updater, CommandHandler, MessageHandler, Filters, ConversationHandler)
from telegram import ReplyKeyboardMarkup, ReplyKeyboardRemove, ChatAction
from python_helpers import functions, number_generator
from functools import wraps
from pathlib import Path
import configparser
import datetime
import os

state = None
city = None
cities_temp = None
zip_temp = None
user = None
zip_code = None
kit_count = None
email = None
confirmation = None
password = None
local_zips = None
group_number = None
first_number = None
second_number = None
member_numbers = []
credentials = []

config = configparser.ConfigParser()
config.read('config.ini')

# Wraps functions as states
STATE, CITY, ZIP_CODE, KIT_COUNT, NUMBERS, CREDS, GROUP, GENERATE, LOG = range(9)

# Keyboards for replies
state_keyboard = [['Utah', 'Texas', 'Arizona'], ['Stop']]
kit_keyboard = [['10', '20', '30'], ['40', '50', '60'], ['70', '80', '90'], ['100']]
quick_start = [['/qstart']]
gen_new = [['No'], ['Yes']]
log_button = [['LOG'], ['Stop']]
state_keyboard = ReplyKeyboardMarkup(state_keyboard, one_time_keyboard=True, resize_keyboard=False)
kit_keyboard = ReplyKeyboardMarkup(kit_keyboard, one_time_keyboard=True)
quick_keyboard = ReplyKeyboardMarkup(quick_start, one_time_keyboard=True, resize_keyboard=True)
generate_keyboard = ReplyKeyboardMarkup(gen_new, one_time_keyboard=True, resize_keyboard=False)
log_button = ReplyKeyboardMarkup(log_button, one_time_keyboard=True, resize_keyboard=False)
remove_keyboard = ReplyKeyboardRemove(remove_keyboard=True)

# Telegram start message for user
with open('./bot-splash.txt', 'r') as f:
    bot_splash = f.read()


def send_action(action):
    """Sends `action` while processing func command."""

    def decorator(func):
        @wraps(func)
        def command_func(update, context, *args, **kwargs):
            context.bot.send_chat_action(chat_id=update.effective_message.chat_id, action=action)
            return func(update, context, *args, **kwargs)

        return command_func

    return decorator


send_typing_action = send_action(ChatAction.TYPING)


@send_typing_action
def start(update, context):
    """Starts bot with splash message"""
    global user
    user = update.message.from_user.first_name
    context.bot.send_message(chat_id=68162307, text='{} started a run.'.format(user))
    update.message.reply_text('{}, %s'.format(
        update.message.from_user.first_name) % bot_splash, reply_markup=state_keyboard)

    return STATE  # <-- this is what will receive the next user input


@send_typing_action
def quick_start(update, context):
    """Starts bot the quick way
       Requests `state` from user
    """
    global user
    user = update.message.from_user.first_name
    context.bot.send_message(chat_id=68162307, text='{} started a run.'.format(user))
    update.message.reply_text('What state?', reply_markup=state_keyboard)
    return STATE


def update_cities():
    """Dynamically gets city list"""
    global cities_temp
    cities_temp = functions.create_dict_and_filter(Path('./States/%s/city-dictionary.txt' % state))
    cities = [cities_temp[x:x + 3] for x in range(0, len(cities_temp), 3)]
    return cities


def update_zip_list():
    """Dynamically gets zip code list"""
    global zip_temp, local_zips
    state_dict = functions.create_dict(Path('./States/%s/city-dictionary.txt' % state))
    zip_temp = functions.get_keys_by_value(state_dict, city)
    local_zips = './States/%s/city-dictionary.txt' % state
    zip_codes = [zip_temp[x:x + 4] for x in range(0, len(zip_temp), 4)]
    return zip_codes


@send_typing_action
def get_state(update, context):
    """Gets `state` from user
       Requests `city` from user
    """
    global state
    state = update.message.text
    cities = update_cities()
    city_keyboard = ReplyKeyboardMarkup(cities, one_time_keyboard=True, resize_keyboard=False)
    update.message.reply_text('What city?', reply_markup=city_keyboard)
    return CITY


@send_typing_action
def get_city(update, context):
    """Gets `city` from user
       Requests `zip code` from user
    """
    global city
    city = update.message.text
    zip_codes = update_zip_list()
    zip_codes_keyboard = ReplyKeyboardMarkup(zip_codes, one_time_keyboard=True, resize_keyboard=False)
    update.message.reply_text('What zip code?', reply_markup=zip_codes_keyboard)
    return ZIP_CODE


@send_typing_action
def get_zip_code(update, context):
    """Gets `zip code` from user
       Requests `kits` from user
    """
    global zip_code
    zip_code = update.message.text
    update.message.reply_text('How many kits?', reply_markup=kit_keyboard)
    return NUMBERS  # <-- this is what will receive the next user input


@send_typing_action
def generate_new_numbers(update, context):
    """Generates `member numbers` if user runs out or if user requests them"""
    global kit_count
    kit_count = update.message.text
    update.message.reply_text('Generate new numbers?', reply_markup=generate_keyboard)
    return KIT_COUNT  # <-- gets answer


@send_typing_action
def get_kit_count(update, context):
    """Checks if user files exist
       Gets `generate numbers` response from user

       If user files exist, this sends confirmation message

       If user files do not exist, this requests:
       `email` and `password` from user
       `box range` from user
    """
    global email, password, group_number, member_numbers
    print('Logging %s kits at %s' % (kit_count, zip_code))
    credentials_file = Path('./Users/%s/ALL/extras/credentials.txt' % user)
    group_file = Path('./Users/%s/ALL/extras/group_number.txt' % user)
    member_file = Path('./Users/%s/ALL/extras/member_numbers.txt' % user)
    if credentials_file.is_file() and group_file.is_file() and member_file.is_file():
        group_number = functions.read_from_file(group_file)
        cred_list = functions.read_and_append(credentials_file)
        for item in cred_list:
            credentials.append(item)
        email = credentials[0]
        password = credentials[1]
        if update.message.text == 'Yes':
            update.message.reply_text('Send box range.\nExample:\n\n50015000 50015099')
            return GENERATE
        if not os.stat(member_file).st_size == 0:
            member_temp = functions.read_and_append(member_file)
            for item in member_temp:
                member_numbers.append(item)
            update.message.reply_text('Found files with necessary information.', reply_markup=log_button)
            return LOG
        else:
            update.message.reply_text('None found. Send box range.\nExample:\n\n50015000 50015099')
            return GENERATE
    update.message.reply_text('Send your email and password.\nExample:\n\n email@gmail.com pAsSworD$&')
    return CREDS  # <-- this is what will receive the next user input


@send_typing_action
def get_creds(update, context):
    """Gets `credentials` from user
       Requests `group number` from user
    """
    global email, password
    credentials_path = Path('./Users/%s/ALL/extras/' % user)
    credentials_file = Path('./Users/%s/ALL/extras/credentials.txt' % user)
    creds = update.message.text
    (email, password) = creds.split()
    credentials.append(email.lower())
    credentials.append(password)
    if not os.path.exists(credentials_path):
        os.makedirs(credentials_path)
    functions.write_lines_to_file(credentials_file, credentials)
    update.message.reply_text('Group number?')
    return GROUP  # <-- this is what will receive the next user input


@send_typing_action
def get_group(update, context):
    """Gets `group number` from user
       Requests `box range` from user
    """
    global group_number
    group_file = Path('./Users/%s/ALL/extras/group_number.txt' % user)
    group_path = Path('./Users/%s/ALL/extras/' % user)
    text = update.message.text
    group_number = text
    update.message.reply_text('Send box range.\nExample:\n\n50015000-50015099')
    if not os.path.exists(group_path):
        os.makedirs(group_path)
    functions.write_to_file(group_file, group_number)
    return GENERATE


@send_typing_action
def generate_numbers(update, context):
    """Generates number range from user input"""
    global first_number, second_number, member_numbers
    text = update.message.text
    (first_number, second_number) = text.split('-')
    member_numbers = number_generator.generate_card_numbers(user, first_number, second_number)
    if len(first_number) != len(second_number):
        update.message.reply_text('You may have entered extra digits, please send them again.')
        return GROUP
    update.message.reply_text('Member numbers were generated', reply_markup=log_button)
    return LOG


@send_typing_action
def begin_logging(update, context):
    """Executes the ruby automation
       Parses results from temp file
       If a screenshot is created during a failure, this sends the image .png
       Ends conversation
    """
    print('%s hit the log button' % user)
    results = []
    data = [user, zip_code, kit_count, local_zips]
    chat_id = update.message.chat.id
    with open('data/temp/temp.txt', 'w') as d:
        for item in data:
            d.write('%s\n' % item)
    update.message.reply_text('Spinning up logger session, results will be sent soon.', reply_markup=remove_keyboard)
    try:
        os.system('ruby ./kit_logger.rb')
    except:
        pass
    with open('data/temp/temp.txt', 'r') as t:
        for line in t:
            results.append(line)
    kits = str(results[4].replace("\n", '')) + ' kits logged'
    time = int(results[5].replace("\n", ''))
    total_time = str(datetime.timedelta(seconds=time))
    try:
        screenshot_name = results[6].replace("\n", '')
        screenshot = './data/screenshots/%s' % screenshot_name
        context.bot.send_photo(chat_id=68162307, photo=open(screenshot, 'rb'))
        context.bot.send_photo(chat_id=chat_id, photo=open(screenshot, 'rb'))
        update.message.reply_text('A failure occurred, please review the screenshot.')
    except:
        pass
    update.message.reply_text('Results:\n%s\nTime: %s' % (kits, total_time), reply_markup=quick_keyboard)
    context.bot.send_message(chat_id=68162307, text='Results:\n%s\nTime: %s' % (kits, total_time))
    done(update, context)
    return ConversationHandler.END


def reset_data():
    """Resets global variables and clears temp file"""
    global state, city, cities_temp, zip_temp, user, zip_code, kit_count, email, password, confirmation,\
        group_number, member_numbers, credentials, first_number, second_number
    state = None
    city = None
    cities_temp = None
    zip_temp = None
    user = None
    zip_code = None
    kit_count = None
    email = None
    password = None
    confirmation = None
    group_number = None
    first_number = None
    second_number = None
    member_numbers = []
    credentials = []
    open('data/temp/temp.txt', 'w').close()


def done(update, context):
    """Resets user data"""
    context.bot.send_message(chat_id=68162307, text='{}\'s run has ended.'.format(user))
    reset_data()
    user_data = context.user_data
    user_data.clear()
    update.message.reply_text('All session data was cleared, see you later!')


def stop(update, context):
    """Stops bot conversation and resets user data"""
    context.bot.send_message(chat_id=68162307, text='{}\'s run has ended using stop command.'.format(user))
    reset_data()
    user_data = context.user_data
    user_data.clear()
    update.message.reply_text('Stopped the session.', reply_markup=quick_keyboard)
    return ConversationHandler.END


def main():
    updater = Updater(config['SECRET']['token'], use_context=True, workers=5)
    dp = updater.dispatcher
    end_handler = MessageHandler(Filters.regex('^Stop$'), stop)
    conv_handler = ConversationHandler(
        entry_points=[CommandHandler('start', start), CommandHandler('qstart', quick_start)],

        states={
            KIT_COUNT: [MessageHandler(Filters.regex('^(10|20|30|40|50|60|70|80|90|100|Yes|No)$'), get_kit_count)],
            STATE: [MessageHandler(Filters.regex('^(Utah|Texas|Arizona)$'), get_state)],
            CITY: [MessageHandler(Filters.text, get_city)],
            ZIP_CODE: [MessageHandler(Filters.text, get_zip_code)],
            NUMBERS: [MessageHandler(Filters.text, generate_new_numbers)],
            CREDS: [MessageHandler(Filters.text, get_creds)],
            GROUP: [MessageHandler(Filters.text, get_group)],
            GENERATE: [MessageHandler(Filters.text, generate_numbers)],
            LOG: [MessageHandler(Filters.regex('^(LOG)$'), begin_logging)]
        },

        fallbacks=[end_handler]
    )
    dp.add_handler(conv_handler)

    updater.start_polling()
    updater.idle()


if __name__ == '__main__':
    main()
