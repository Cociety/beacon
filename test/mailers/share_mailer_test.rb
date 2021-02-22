require 'test_helper'

class ShareMailerTest < ActionMailer::TestCase
  setup do
    @justin = customers(:justin)
    @melissa = customers(:melissa)
    @share = shares(:writer_tree_one_with_non_customer)
  end

  test 'tree_shared' do
    email = ShareMailer.with(share: @share).tree_shared

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['support@cociety.org'], email.from
    assert_equal ['non_customer@cociety.org'], email.to
    assert_equal 'Justin Robinson shared a Beacon Tree with you', email.subject
    assert_equal read_fixture('tree_shared.html').join, email.html_part.body.to_s
  end
end
