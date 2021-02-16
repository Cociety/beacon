class Customer < CocietyRecord
  include Rolable

  # We sign in with Cociety by going to sign_in_url and sign_out_url and being redirected back to Beacon
  devise :database_authenticatable, :timeoutable, timeout_in: 2.weeks
  has_person_name
end
