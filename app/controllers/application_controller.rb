require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if Helpers.is_logged_in?(session)
      redirect '/tweets'
    else
      erb :'users/signup'
    end
  end

  post '/signup' do
    if params['username'].empty? || params['password'].empty? || params['email'].empty?
      redirect '/signup'
    else
      @user = User.new(username: params['username'], email: params['email'], password: params['password'])
      @user.save
      session[:id] = @user.id
    end
    redirect '/tweets'
  end


  get '/login' do
    if Helpers.is_logged_in?(session)
      redirect '/tweets'
    else
      erb :'users/login'
    end
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:id] = @user.id
      redirect '/tweets'
    else
      redirect '/signup'
    end
  end

  get '/logout' do
    if Helpers.is_logged_in?(session)
      session.clear
      redirect '/login'
    else
    redirect '/'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end

  get '/tweets' do
    if Helpers.is_logged_in?(session)
      @tweets = Tweet.all
      erb :'tweets/tweets'
    else
      redirect '/login'
    end
  end

  post '/tweets' do
    @user = Helpers.current_user(session)
    if !params[:content].empty?
      @tweet = @user.tweets.create(content: params[:content])
    else
      redirect '/tweets/new'
    end
  end

  get '/tweets/new' do
    if Helpers.is_logged_in?(session)
      erb :'tweets/create_tweet'
    else
      redirect '/login'
    end
  end

  get '/tweets/:id' do
    if Helpers.is_logged_in?(session)
      @tweet = Tweet.find_by(id: params[:id])
      erb :'tweets/show_tweet'
    else
      redirect '/login'
    end
  end

  post '/tweets/:id/delete' do
    @tweet = Tweet.find_by(id: params[:id])
    @tweet.delete if @tweet.user == Helpers.current_user(session)
    redirect '/tweets'
  end

  get '/tweets/:id/edit' do
    if Helpers.is_logged_in?(session)
      @tweet = Tweet.find_by(id: params[:id])
      erb :'tweets/edit_tweet'
    else
      redirect '/login'
    end
  end

  post '/tweets/:id/edit' do
    @tweet = Tweet.find_by(id: params[:id])
    @tweet.update(content: params[:content])
    @tweet.save
  end
end
