# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120825000821) do

  create_table "blogs", :force => true do |t|
    t.integer  "group_id"
    t.string   "name"
    t.string   "url"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "password"
    t.string   "custom_domain"
    t.string   "blg_id"
    t.string   "branch"
  end

  add_index "blogs", ["group_id"], :name => "index_blogs_on_group_id"

  create_table "groups", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["user_id"], :name => "index_groups_on_user_id"

  create_table "tasks", :force => true do |t|
    t.string   "usr_id"
    t.string   "grp_id"
    t.string   "action"
    t.string   "domain"
    t.string   "qty"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "blg_id"
  end

  create_table "tasks_users", :id => false, :force => true do |t|
    t.integer "task_id"
    t.integer "user_id"
  end

  add_index "tasks_users", ["task_id", "user_id"], :name => "index_tasks_users_on_task_id_and_user_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.string   "plan_id"
    t.string   "subscr_id"
    t.boolean  "super_admin"
    t.boolean  "demo_user"
  end

end
