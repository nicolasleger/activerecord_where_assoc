# frozen_string_literal: true

# Avoid a message about default database used
ENV["DB"] ||= "sqlite3"

require_relative "../test/support/load_test_env"
require_relative "schema"
require_relative "models"
require_relative "some_data"
require "niceql"

class Examples
  def puts_doc
    puts "## Simple examples"
    puts

    output_example(<<-DESC, <<-RUBY)
      Posts that have a least one comment
    DESC
      Post.where_assoc_exists(:comments)
    RUBY

    output_example(<<-DESC, <<-RUBY)
      Posts that have no comments
    DESC
      Post.where_assoc_not_exists(:comments)
    RUBY

    output_example(<<-DESC, <<-RUBY)
      Posts that have a least 50 comment
    DESC
      Post.where_assoc_count(50, :<=, :comments)
    RUBY

    puts "## Examples with condition / scope"
    puts

    output_example(<<-DESC, <<-RUBY)
      comments of `my_post` that were made by an admin (Using a hash)
    DESC
      my_post.comments.where_assoc_exists(:author, is_admin: true)
    RUBY

    output_example(<<-DESC, <<-RUBY)
      comments of `my_post` that were not made by an admin (Using scope)
    DESC
      my_post.comments.where_assoc_not_exists(:author, &:admins)
    RUBY

    output_example(<<-DESC, <<-RUBY)
      Posts that have at least 5 reported comments (Using array condition)
    DESC
      Post.where_assoc_count(5, :<=, :comments, ["is_reported = ?", true])
    RUBY

    output_example(<<-DESC, <<-RUBY)
      Posts made by an admin (Using a string)
    DESC
      Post.where_assoc_exists(:author, "is_admin = 't'")
    RUBY

    output_example(<<-DESC, <<-RUBY)
      comments of `my_post` that were not made by an admin (Using block and a scope)
    DESC
      my_post.comments.where_assoc_not_exists(:author) { admins }
    RUBY

    output_example(<<-DESC, <<-RUBY)
      Posts that have at least 5 reported comments (Using block with #where)
    DESC
      Post.where_assoc_count(5, :<=, :comments) { where(is_reported: true) }
    RUBY

    output_example(<<-DESC, <<-RUBY)
      comments made in replies to my_user's post
    DESC
      Comment.where_assoc_exists(:post, author_id: my_user.id)
    RUBY

    puts "## Complex / powerful examples"
    puts

    output_example(<<-DESC, <<-RUBY)
      posts with a comment by an admin (uses array to go through multiple associations)
    DESC
      Post.where_assoc_exists([:comments, :author], is_admin: true)
    RUBY

    output_example(<<-DESC, <<-RUBY)
      posts where the author also commented on the post (use conditions between posts)
    DESC
      Post.where_assoc_exists(:comments, "posts.author_id = comments.author_id")
    RUBY

    output_example(<<-DESC, <<-RUBY)
      posts with a reported comment made by an admin (must be the same comments)
    DESC
      Post.where_assoc_exists(:comments, is_reported: true) {
        where_assoc_exists(:author, is_admin: true)
      }
    RUBY

    output_example(<<-DESC, <<-RUBY)
      posts with a reported comment and a comment by an admin (can be different or same comments)
    DESC
      my_user.posts.where_assoc_exists(:comments, is_reported: true)
                   .where_assoc_exists([:comments, :author], is_admin: true)
    RUBY
  end


  # Below is just helpers for #puts_doc

  def my_post
    Post.order(:id).first
  end

  def my_user
    User.order(:id).first
  end

  def my_comment
    User.order(:id).first
  end

  def output_example(description, ruby)
    description = description.strip_heredoc
    ruby = ruby.strip_heredoc

    relation = eval(ruby) # rubocop:disable Security/Eval
    # Just making sure the query doesn't fail
    relation.to_a

    # #to_niceql formats the SQL a little
    sql = relation.to_niceql

    puts "```ruby"
    puts description.split("\n").map { |s| "# #{s}" }.join("\n")
    puts ruby
    puts "```"
    puts "```sql\n#{sql}\n```"
    puts
    puts "---"
    puts
  end
end

# Lets make this a little denser
Niceql::Prettifier::INLINE_VERBS << "|FROM"

Examples.new.puts_doc
