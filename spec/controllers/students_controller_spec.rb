require 'spec_helper.rb'

describe StudentsController do

  def mock_student(stubs={})
    @mock_student ||=mock_model(Student,stubs).as_null_object
  end

  describe "GET index" do
    it "assign all students as @products" do
      Student.stub(:all) {[mock_student]}
      get :index
      assigns(:students).should eq([mock_student])
    end
  end

end

