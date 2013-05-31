class UserMailer < ActionMailer::Base
 
 def support_email(current_user, msg)
     
      @msg = msg
      @current_user = current_user
     

       mail(
         :subject => "CdNB2B - #{@current_user.name} contacted support",
         :to      => "ngrichyj4@gmail.com",
         :from    => "r.aberefa@cdnb2b.com",
         :tag     => "CdNB2B"
       )
       
   end

   def task_email(current_user, task)
     
      @current_user = current_user
      @task = task

       mail(
         :subject => "CdNB2B - #{@current_user.name} added a new task",
         :to      => "ngrichyj4@gmail.com",
         :from    => "r.aberefa@cdnb2b.com",
         :tag     => "CdNB2B"
       )
       
   end
end