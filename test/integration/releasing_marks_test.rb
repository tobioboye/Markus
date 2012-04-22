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

      # Create an assignment
      @assignment = Assignment.make(:allow_web_submits => true, :group_min => 1)
      
      # Create a student with a grouping for that student and a submission with a result for that grouping
      @group = Group.make
      @grouping = Grouping.make(:group => @group, :assignment => @assignment)      
      @membership = StudentMembership.make(:membership_status => 'inviter', :grouping => @grouping)
      @student = @membership.user
      @submission = Submission.make(:grouping => @grouping)
      @result = Result.make(:submission => @submission)

      # Create a TA and assign the TA to be the grader of the TA
      @ta_membership = TaMembership.make(:membership_status => :accepted)
      @grader = @ta_membership.user
    end

    should "Assign student grouping to a grader" do
      # Set up session variables for each user
      session_vars_admin = { 'uid' => @admin.id, 'timeout' => 3.days.from_now }
      session_vars_ta = {'uid' => @grader.id, 'timeout' => 3.days.from_now }
      session_vars_student = {'uid' => @student.id, 'timeout' => 3.days.from_now }
      get_via_redirect add_grader_to_grouping_assignment_graders_path(:assignment_id => @assignment.id, 
                                                                      :grader_id => @grader.id,
                                                                      :grouping_id => @grouping.id),
                                                                      session_vars_admin
      assert_response :success

      # Admin collects the assignment
      get_via_redirect collect_all_submissions_assignment_submissions_path(:assignment_id => @assignment.id, 
                                                                           :grouping_id => @grouping.id),
                                                                           session_vars_admin
      assert_response :success

      # TA grade the assignments and mark them as completed assign a grade to them by assigning an extra mark

      get_via_redirect add_extra_mark_assignment_submission_result_path(:assignment_id => @assignment.id,
                                                                        :submission_id => @submission.id,
                                                                        :id => @result.id, 
                                                                        :extra_mark => 10),
                                                                        session_vars_ta
      assert_response :success

      # TA marks the assignment as completed
      @result.marking_state = Result::MARKING_STATES[:complete]
      post_via_redirect update_marking_state_assignment_submission_result_path(:assignment_id => @assignment.id,
                                                                               :submission_id => @submission.id,
                                                                               :id => @result.id),
                                                                               session_vars_ta
      assert_response :success

      # Admin releases the assignment
      get_via_redirect set_released_to_students_assignment_submission_result_path(:assignment_id => @assignment.id,
                                                                                  :submission_id => @submission.id,
                                                                                  :id => @result.id,
                                                                                  :value => true),
                                                                                  session_vars_admin
      assert_response :success

      # Student views her marks
      get_via_redirect view_marks_assignment_submission_result_path(:assignment_id => @assignment.id,
                                                                    :submission_id => @submission.id,
                                                                    :id => @result.id)
      assert_response :success
    end
  end
end
