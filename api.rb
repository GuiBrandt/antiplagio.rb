require 'sinatra'
require 'firebase'

require_relative 'lib/submissions'

def init_firebase
    firebase_url = ENV['FIREBASE_URL']
    private_key = File.open(ENV['FIREBASE_KEY_FILE']).read

    $firebase = Firebase::Client.new(firebase_url, private_key)
end

def init_endpoints
    post '/submit/:user_id/:question_id' do
        content = request.body.read
        Submission.new(params['user_id'], params['question_id'], content).submit
    end

    get '/simmilar/:user_id/:question_id' do |user_id, question_id|
        # TODO: Listar as submissões similares à de `user_id` para
        # `question_id`
    end
end

init_firebase
init_endpoints