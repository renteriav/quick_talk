class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    
    user ||= User.new # guest user (not logged in)
    if user.is_admin?
      can :manage, :all
    elsif user.is_accountant?
      can :manage, Brand
      can :read, Dashboard
    else
      can :read, Dashboard
    end
  end

end