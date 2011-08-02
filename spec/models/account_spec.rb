#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Account do

  it "should provide a list of courses" do
    @account = Account.new
    lambda{@account.courses}.should_not raise_error
  end
  
  context "equella_settings" do
    it "should respond to :equella_settings" do
      Account.new.should respond_to(:equella_settings)
      Account.new.equella_settings.should be_nil
    end
    
    it "should return the equella_settings data if defined" do
      a = Account.new
      a.equella_endpoint = "http://oer.equella.com/signon.do"
      a.equella_settings.should_not be_nil
      a.equella_settings.endpoint.should eql("http://oer.equella.com/signon.do")
      a.equella_settings.default_action.should_not be_nil
    end
  end
  
  # it "should have an atom feed" do
    # account_model
    # @a.to_atom.should be_is_a(Atom::Entry)
  # end
  
  def process_csv_data(account, lines)
    tmp = Tempfile.new("sis_rspec")
    path = "#{tmp.path}.csv"
    tmp.close!
    File.open(path, "w+") { |f| f.puts lines.join "\n" }
    importer = SIS::SisCsv.process(@account, :files => [path],
        :allow_printing => false)
    File.unlink path
    importer.warnings.should == []
    importer.errors.should == []
  end

  context "course lists" do
    before(:each) do
      @account = Account.create!
      process_csv_data(@account, [
        "user_id,login_id,first_name,last_name,email,status",
        "U001,user1,User,One,user1@example.com,active",
        "U002,user2,User,Two,user2@example.com,active",
        "U003,user3,User,Three,user3@example.com,active",
        "U004,user4,User,Four,user4@example.com,active",
        "U005,user5,User,Five,user5@example.com,active",
        "U006,user6,User,Six,user6@example.com,active",
        "U007,user7,User,Seven,user7@example.com,active",
        "U008,user8,User,Eight,user8@example.com,active",
        "U009,user9,User,Nine,user9@example.com,active",
        "U010,user10,User,Ten,user10@example.com,active",
        "U011,user11,User,Eleven,user11@example.com,deleted"
      ])
      process_csv_data(@account, [
        "term_id,name,status,start_date,end_date",
        "T001,Term 1,active,,",
        "T002,Term 2,active,,",
        "T003,Term 3,active,,"
      ])
      process_csv_data(@account, [
        "course_id,short_name,long_name,account_id,term_id,status",
        "C001,C001,Test Course 1,,T001,active",
        "C002,C002,Test Course 2,,T001,deleted",
        "C003,C003,Test Course 3,,T002,deleted",
        "C004,C004,Test Course 4,,T002,deleted",
        "C005,C005,Test Course 5,,T003,active",
        "C006,C006,Test Course 6,,T003,active",
        "C007,C007,Test Course 7,,T003,active",
        "C008,C008,Test Course 8,,T003,active",
        "C009,C009,Test Course 9,,T003,active",
        "C001S,C001S,Test search Course 1,,T001,active",
        "C002S,C002S,Test search Course 2,,T001,deleted",
        "C003S,C003S,Test search Course 3,,T002,deleted",
        "C004S,C004S,Test search Course 4,,T002,deleted",
        "C005S,C005S,Test search Course 5,,T003,active",
        "C006S,C006S,Test search Course 6,,T003,active",
        "C007S,C007S,Test search Course 7,,T003,active",
        "C008S,C008S,Test search Course 8,,T003,active",
        "C009S,C009S,Test search Course 9,,T003,active"
      ])
      process_csv_data(@account, [
        "section_id,course_id,name,start_date,end_date,status",
        "S001,C001,Sec1,,,active",
        "S002,C002,Sec2,,,active",
        "S003,C003,Sec3,,,active",
        "S004,C004,Sec4,,,active",
        "S005,C005,Sec5,,,active",
        "S006,C006,Sec6,,,active",
        "S007,C007,Sec7,,,deleted",
        "S008,C001,Sec8,,,deleted",
        "S009,C008,Sec9,,,active",
        "S001S,C001S,Sec1,,,active",
        "S002S,C002S,Sec2,,,active",
        "S003S,C003S,Sec3,,,active",
        "S004S,C004S,Sec4,,,active",
        "S005S,C005S,Sec5,,,active",
        "S006S,C006S,Sec6,,,active",
        "S007S,C007S,Sec7,,,deleted",
        "S008S,C001S,Sec8,,,deleted",
        "S009S,C008S,Sec9,,,active"
      ])
      process_csv_data(@account, [
        "course_id,user_id,role,section_id,status,associated_user_id",
        ",U001,student,S001,active,",
        ",U002,student,S002,active,",
        ",U003,student,S003,active,",
        ",U004,student,S004,active,",
        ",U005,student,S005,active,",
        ",U006,student,S006,deleted,",
        ",U007,student,S007,active,",
        ",U008,student,S008,active,",
        ",U009,student,S005,deleted,",
        ",U001,student,S001S,active,",
        ",U002,student,S002S,active,",
        ",U003,student,S003S,active,",
        ",U004,student,S004S,active,",
        ",U005,student,S005S,active,",
        ",U006,student,S006S,deleted,",
        ",U007,student,S007S,active,",
        ",U008,student,S008S,active,",
        ",U009,student,S005S,deleted,"
      ])
      
    end
    
    context "fast list" do
      it "should list associated courses" do
        @account.fast_all_courses.map(&:sis_source_id).sort.should == [
          "C001", "C005", "C006", "C007", "C008", "C009",
          "C001S", "C005S", "C006S", "C007S", "C008S", "C009S", ].sort
      end
    
      it "should list associated courses by term" do
        @account.fast_all_courses({:term => EnrollmentTerm.find_by_sis_source_id("T001")}).map(&:sis_source_id).sort.should == ["C001", "C001S"]
        @account.fast_all_courses({:term => EnrollmentTerm.find_by_sis_source_id("T002")}).map(&:sis_source_id).sort.should == []
        @account.fast_all_courses({:term => EnrollmentTerm.find_by_sis_source_id("T003")}).map(&:sis_source_id).sort.should == ["C005", "C006", "C007", "C008", "C009", "C005S", "C006S", "C007S", "C008S", "C009S"].sort
      end
    
      it "should list associated nonenrollmentless courses" do
        @account.fast_all_courses({:hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == ["C001", "C005", "C007", "C001S", "C005S", "C007S"].sort #C007 probably shouldn't be here, cause the enrollment section is deleted, but we kinda want to minimize database traffic
      end

      it "should list associated nonenrollmentless courses by term" do
        @account.fast_all_courses({:term => EnrollmentTerm.find_by_sis_source_id("T001"), :hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == ["C001", "C001S"]
        @account.fast_all_courses({:term => EnrollmentTerm.find_by_sis_source_id("T002"), :hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == []
        @account.fast_all_courses({:term => EnrollmentTerm.find_by_sis_source_id("T003"), :hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == ["C005", "C007", "C005S", "C007S"].sort
      end
    end
  
    context "name searching" do
      it "should list associated courses" do
        @account.courses_name_like("search").map(&:sis_source_id).sort.should == [
          "C001S", "C005S", "C006S", "C007S", "C008S", "C009S"]
      end
      
      it "should list associated courses by term" do
        @account.courses_name_like("search", {:term => EnrollmentTerm.find_by_sis_source_id("T001")}).map(&:sis_source_id).sort.should == ["C001S"]
        @account.courses_name_like("search", {:term => EnrollmentTerm.find_by_sis_source_id("T002")}).map(&:sis_source_id).sort.should == []
        @account.courses_name_like("search", {:term => EnrollmentTerm.find_by_sis_source_id("T003")}).map(&:sis_source_id).sort.should == ["C005S", "C006S", "C007S", "C008S", "C009S"]
      end
    
      it "should list associated nonenrollmentless courses" do
        @account.courses_name_like("search", {:hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == ["C001S", "C005S", "C007S"] #C007 probably shouldn't be here, cause the enrollment section is deleted, but we kinda want to minimize database traffic
      end

      it "should list associated nonenrollmentless courses by term" do
        @account.courses_name_like("search", {:term => EnrollmentTerm.find_by_sis_source_id("T001"), :hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == ["C001S"]
        @account.courses_name_like("search", {:term => EnrollmentTerm.find_by_sis_source_id("T002"), :hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == []
        @account.courses_name_like("search", {:term => EnrollmentTerm.find_by_sis_source_id("T003"), :hide_enrollmentless_courses => true}).map(&:sis_source_id).sort.should == ["C005S", "C007S"]
      end
    end
  end
  
  context "services" do
    before(:each) do
      @a = Account.new
    end
    it "should be able to specify a list of enabled services" do
      @a.allowed_services = 'facebook,twitter'
      @a.service_enabled?(:facebook).should be_true
      @a.service_enabled?(:twitter).should be_true
      @a.service_enabled?(:diigo).should be_false
      @a.service_enabled?(:avatars).should be_false
    end
    
    it "should not enable services off by default" do
      @a.service_enabled?(:facebook).should be_true
      @a.service_enabled?(:avatars).should be_false
    end
    
    it "should add and remove services from the defaults" do
      @a.allowed_services = '+avatars,-facebook'
      @a.service_enabled?(:avatars).should be_true
      @a.service_enabled?(:twitter).should be_true
      @a.service_enabled?(:facebook).should be_false
    end
    
    it "should allow settings services" do
      lambda {@a.enable_service(:completly_bogs)}.should raise_error
      
      @a.disable_service(:twitter)
      @a.service_enabled?(:twitter).should be_false
      
      @a.enable_service(:twitter)
      @a.service_enabled?(:twitter).should be_true
    end
    
    it "should use + and - by default when setting service availabilty" do
      @a.enable_service(:twitter)
      @a.service_enabled?(:twitter).should be_true
      @a.allowed_services.should be_nil
      
      @a.disable_service(:twitter)
      @a.allowed_services.should match('\-twitter')
      
      @a.disable_service(:avatars)
      @a.service_enabled?(:avatars).should be_false
      @a.allowed_services.should_not match('avatars')
      
      @a.enable_service(:avatars)
      @a.service_enabled?(:avatars).should be_true
      @a.allowed_services.should match('\+avatars')
    end

    it "should be able to set service availibity for previously hard-coded values" do
      @a.allowed_services = 'avatars,facebook'
      
      @a.enable_service(:twitter)
      @a.service_enabled?(:twitter).should be_true
      @a.allowed_services.should match(/twitter/)
      @a.allowed_services.should_not match(/[+-]/)
      
      @a.disable_service(:facebook)
      @a.allowed_services.should_not match(/facebook/)
      @a.allowed_services.should_not match(/[+-]/)
      
      @a.disable_service(:avatars)
      @a.disable_service(:twitter)
      @a.allowed_services.should be_nil
    end
  end
  
  context "settings=" do
    it "should filter disabled settings" do
      a = Account.new
      a.root_account_id = 1
      a.settings = {'global_javascript' => 'something'}.with_indifferent_access
      a.settings[:global_javascript].should eql(nil)
      
      a.root_account_id = nil
      a.settings = {'global_javascript' => 'something'}.with_indifferent_access
      a.settings[:global_javascript].should eql(nil)
      
      a.settings[:global_includes] = true
      a.settings = {'global_javascript' => 'something'}.with_indifferent_access
      a.settings[:global_javascript].should eql('something')

      a.settings = {'error_reporting' => 'string'}.with_indifferent_access
      a.settings[:error_reporting].should eql(nil)
      
      a.settings = {'error_reporting' => {
        'action' => 'email',
        'email' => 'bob@yahoo.com',
        'extra' => 'something'
      }}.with_indifferent_access
      a.settings[:error_reporting].should be_is_a(Hash)
      a.settings[:error_reporting][:action].should eql('email')
      a.settings[:error_reporting][:email].should eql('bob@yahoo.com')
      a.settings[:error_reporting][:extra].should eql(nil)
    end
  end
  
  context "turnitin secret" do
    it "should decrypt the turnitin secret to the original value" do
      a = Account.new
      a.turnitin_shared_secret = "asdf"
      a.turnitin_shared_secret.should eql("asdf")
      a.turnitin_shared_secret = "2t87aot72gho8a37gh4g[awg'waegawe-,v-3o7fya23oya2o3"
      a.turnitin_shared_secret.should eql("2t87aot72gho8a37gh4g[awg'waegawe-,v-3o7fya23oya2o3")
    end
  end

  it "should make a default enrollment term if necessary" do
    a = Account.create!(:name => "nada")
    a.enrollment_terms.size.should == 1
    a.enrollment_terms.first.name.should == "Default Term"

    # don't create a new default term for sub-accounts
    a2 = a.all_accounts.create!(:name => "sub")
    a2.enrollment_terms.size.should == 0
  end

  context "page view reports" do
    before(:each) do
      @a = Account.create!(:name => 'nada')
    end
    it "should build hourly reports" do
      lambda{@a.page_views_by_hour}.should_not raise_error
    end
    it "should build daily reports" do
      lambda{@a.page_views_by_day}.should_not raise_error
    end
  end

  def account_with_admin_and_restricted_user(account)
    account.add_account_membership_type('Restricted Admin')
    admin = User.create
    user = User.create
    account.account_users.create(:user => admin, :membership_type => 'AccountAdmin')
    account.account_users.create(:user => user, :membership_type => 'Restricted Admin')
    [ admin, user ]
  end


  it "should set up access policy correctly" do
    # Set up a hierarchy of 4 accounts - a root account, a sub account,
    # a sub sub account, and SiteAdmin account.  Create a 'Restricted Admin'
    # role in each one, and create an admin user and a user in the restricted
    # admin role for each one
    root_account = Account.create
    sub_account = Account.create(:parent_account => root_account)
    sub_sub_account = Account.create(:parent_account => sub_account)

    hash = {}
    hash[:site_admin] = { :account => Account.site_admin}
    hash[:root] = { :account => root_account}
    hash[:sub] = { :account => sub_account}
    hash[:sub_sub] = { :account => sub_sub_account}

    hash.each do |k, v|
      admin, user = account_with_admin_and_restricted_user(v[:account])
      hash[k][:admin] = admin
      hash[k][:user] = user
    end

    limited_access = [ :read, :manage, :update, :delete ]
    full_access = RoleOverride.permissions.map { |k, v| k } + limited_access
    # site admin has access to everything everywhere
    hash.each do |k, v|
      account = v[:account]
      account.check_policy(hash[:site_admin][:admin]).should == full_access
      account.check_policy(hash[:site_admin][:user]).should == limited_access
    end

    # root admin has access to everything except site admin
    account = hash[:site_admin][:account]
    account.check_policy(hash[:root][:admin]).should == []
    account.check_policy(hash[:root][:user]).should == []
    hash.each do |k, v|
      next if k == :site_admin
      account = v[:account]
      account.check_policy(hash[:root][:admin]).should == full_access
      account.check_policy(hash[:root][:user]).should == limited_access
    end

    # sub account has access to sub and sub_sub
    hash.each do |k, v|
      next unless k == :site_admin || k == :root
      account = v[:account]
      account.check_policy(hash[:sub][:admin]).should == []
      account.check_policy(hash[:sub][:user]).should == []
    end
    hash.each do |k, v|
      next if k == :site_admin || k == :root
      account = v[:account]
      account.check_policy(hash[:sub][:admin]).should == full_access
      account.check_policy(hash[:sub][:user]).should == limited_access
    end

    # Grant 'Restricted Admin' a specific permission, and re-check everything
    some_access = [:read_reports] + limited_access
    hash.each do |k, v|
      account = v[:account]
      account.role_overrides.create(:permission => 'read_reports', :enrollment_type => 'Restricted Admin', :enabled => true)
    end
    RoleOverride.clear_cached_contexts
    hash.each do |k, v|
      account = v[:account]
      account.check_policy(hash[:site_admin][:admin]).should == full_access
      account.check_policy(hash[:site_admin][:user]).should == some_access
    end

    account = hash[:site_admin][:account]
    account.check_policy(hash[:root][:admin]).should == []
    account.check_policy(hash[:root][:user]).should == []
    hash.each do |k, v|
      next if k == :site_admin
      account = v[:account]
      account.check_policy(hash[:root][:admin]).should == full_access
      account.check_policy(hash[:root][:user]).should == some_access
    end

    # sub account has access to sub and sub_sub
    hash.each do |k, v|
      next unless k == :site_admin || k == :root
      account = v[:account]
      account.check_policy(hash[:sub][:admin]).should == []
      account.check_policy(hash[:sub][:user]).should == []
    end
    hash.each do |k, v|
      next if k == :site_admin || k == :root
      account = v[:account]
      account.check_policy(hash[:sub][:admin]).should == full_access
      account.check_policy(hash[:sub][:user]).should == some_access
    end
  end

end