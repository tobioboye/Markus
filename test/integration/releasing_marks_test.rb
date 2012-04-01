# require 'test_helper'
#    require File.join(File.dirname(__FILE__), 'authenticated_controller_test')
require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'blueprints', 'blueprints')
require File.join(File.dirname(__FILE__), '..', 'blueprints', 'helper')
require 'shoulda'
require 'mocha'

class ReleasingMarksTest < ActionDispatch::IntegrationTest
  context "The instructor has created an assignment, the student has made a submission" do
    setup do
      # Create an instructor and TA
      @admin = Admin.make
      @ta_membership = TaMembership.make(:membership_status => :accepted, :grouping => @grouping)
      @grader = @ta_membership.user
      
      # Create an assignment
      @assignment = Assignment.make(:allow_web_submits => true, :group_min => 1)

      # Create a student with a grouping for that student, and create a submission for that grouping
      @group = Group.make
      @grouping = Grouping.make(:group => @group, :assignment => @assignment)
      @membership = StudentMembership.make(:membership_status => 'inviter', :grouping => @grouping)
      @student = @membership.user
      @submission = Submission.make(:grouping => @grouping)

      Assignment.stubs(:find).returns(@assignment)
      @assignment.expects(:short_identifier).once.returns('a1')
      @assignment.submission_rule.expects(:can_collect_now?).once.returns(false)
      @assignment.groupings.expects(:all).returns([@grouping])
    end

    should "Assign student grouping to a grader" do
      # Assign the student to the TA
      debugger
      get_via_redirect add_grader_to_grouping_assignment_graders_path(:assignment_id => @assignment.id, 
                                                                      :grader_id => @grader.id, 
                                                                      :grouping_id => @grouping.id)
      
      assert_response :success       
    end                       
    # # Create the Grade entry for the current student and assign a grade to the student
    #   @grade_entry_form = GradeEntryForm.make
    #   @grade_entry_form_with_grade_entry_items = make_grade_entry_form_with_multiple_grade_entry_items
    #   @grade_entry_student = @grade_entry_form_with_grade_entry_items.grade_entry_students.make(:user => @student)
    #   @grade_entry_form_with_grade_entry_items.grade_entry_items.each do |grade_entry_item|
    #     @grade_entry_student.grades.make(:grade_entry_item => grade_entry_item, :grade => 5)
    #   end
  end

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

end
