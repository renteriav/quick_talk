module Api
  module V1
    class UploadsController < ApplicationController
      skip_before_filter :verify_authenticity_token

      def new
        res = '{ "success": "true" } ' + params.inspect.as_json
        render json: res
      end

      def index
        redirect_to root_path
      end

      def create
        #action = 'POST api/v1/uploads#create'

        guid = params[:guid] || ''
        description = params[:description] || ''
        
        if params[:transaction_type] == 'mileage'
          trip_date = params[:trip_date] || nil
          trip_time = params[:trip_time] || nil
          distance = params[:distance] || nil
        else
          payee = params[:payee] || ''
          transaction_type = params[:transaction_type] || ''
          transaction_date = params[:transaction_date] || Time.now
          payment_method = params[:payment_method] || ''
          amount = params[:amount] || ''
        end
        
        @user = User.where({ guid: guid })
        if @user.any?
          @user = @user.first
        else
          @user = User.where({ guid_alt: guid })
          if !@user.any?
            message = "Invalid guid"
            return render_response(false, message)
          else
            @user = @user.first
          end
        end

        image_content = ''
        if params[:image]
          if !params[:image].empty?
            #image_file_raw = params[:image].tempfile
            #image_file = File.open(image_file_raw, "rb")
            #image_content = image_file.read
            image_content = params[:image].split().join('+')
          end
        end
        
        #for miles
        if params[:transaction_type] == 'mileage'
          @mile = @user.miles.create({
            base_64_image: image_content,
            description: description,
            distance: distance,
            trip_time: trip_time,
            trip_date: trip_date
          })
          @mile.convert_base_64
          message = "mileage created succesfully"
          return render_response(true, message)
        else
# =begin
          words = description.split(' ')

          if words.length == 1 && !@user.is_accountant?
            # this might be a relink_code
            relink_code = words[0].strip
            possible_relink_code_matches = User.where({ relink_code: words })
            if possible_relink_code_matches.any?
              accountant = possible_relink_code_matches.first
              preexisting_relationships = accountant.relationships.where({ client_id: @user.id })
              if !preexisting_relationships.any?
                # delete any 5mb connections
                fivemb_relationships = accountant.relationships.where({ user_id: 4, client_id: @user.id })
                if fivemb_relationships.any?
                  fivemb_relationships.destroy_all
                end
                accountant.relationships.create({ client_id: @user.id })
                accountant.relink_code = nil
                accountant.save
              end
            end
          end


          # look for goodwill
           words.map!{ |w| w.downcase }

           if words.include? 'goodwill'
             # this is a goodwill update
             payee = 'Goodwill'
             transaction_type = 'donation (charitable contribution)'
             is_donation = true
           end

           if words.include? 'dollars'
             i = words.index('dollars') - 1
             amount = words[i]
           end

           if (words.include? 'donation' || 'donate' || 'donated' || 'charity' || 'charitable')
             transaction_type = 'donation (charitable contribution)'
           end

           words.each do |word|
             if word.include? '$'
               amount = word[1..-1].to_s
             end
           end

          # get proper nouns from description
          proper_nouns = []
          if !(/[[:upper:]]/.match(description)).nil?
            words = description.split(' ')
            words.each do |word|
              if /[[:upper:]]/.match(word)
                cap_char = /[[:upper:]]/.match(word).to_s
                if !cap_char.nil?
                  proper_noun = "#{cap_char}#{word.split(cap_char)[1]}"
                  proper_nouns.push proper_noun.to_s.downcase
                end
              end
            end
          end

           #iterate through proper nouns and check against companies
           possibles = []
           if proper_nouns.any?
             proper_nouns.each do |proper_noun|
               company_query = Company.where("matchables like ?", "%#{proper_noun.downcase}%").to_sql
               companies = Company.find_by_sql(company_query)
               if companies.any?
                 companies.each do |company|
                   matchables = company.matchables.split(',')
                   if matchables.include? proper_noun
                     possibles.push company.id
                   end
                 end
               end
             end
             # get occurences of matches
             counts = Hash.new(0)
             possibles.each do |v|
               counts[v] += 1
             end
             # sort by frequency
             if !counts.empty?
               best_match = counts.sort_by{|k,v| v}.last[0]
               company = Company.find(best_match)
               if company
                 downcased_words = words.map{ |w| w.downcase }
                 must_matchables = company.matchables.split(',')
                 it_matches = true
                 must_matchables.each do |mm|
                   it_matches = false if !downcased_words.include? mm
                 end
                 if it_matches
                   payee = company.name.to_s
                 end
               end
             end
           end
          transaction_type = "business" if transaction_type.empty?

          # detect payment method
          available_payment_methods = [
            'paid in cash',
            'using cash',
            'cash',
            'visa card ending in',
            'visa ending in',
            'visa card',
            'visa',
            'mastercard ending in',
            'mastercard',
            'discover card ending in',
            'discover ending in',
            'discover card',
            'discover',
            'american express card ending in',
            'american express ending in',
            'american express card',
            'american express',
            'amex card ending in',
            'amex ending in',
            'amex card',
            'amex',
          ]
           ldescription = description.split(' ').map!{ |w| w.downcase }.join(' ')
           available_payment_methods.each do |pm|
             if ldescription.include? pm
               this_payment_method = pm.split(' ').map!{ |w| w.capitalize }.join(' ')
               payment_method = this_payment_method
               # get next "word" and see if it is a number
               split_desc = ldescription.split(pm)
               temp = ldescription.split(pm)[1]
               if temp 
                 next_word = temp.split(' ')[0]
                 if next_word =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
                   payment_method = "#{this_payment_method}: #{next_word}"
                 end
               end
             end
           end

          # extract amount string into cents
          if amount.include? '.'
            amount_cents = amount.gsub(/\D/, '').to_i
          else
            amount_cents = amount.gsub(/\D/, '').to_i * 100
          end
# =end
          #amount_cents = amount.gsub(/\D/, '').to_i
          @document = @user.documents.create({
            base_64_image: image_content,
            description: description,
            # metadata: metadata.to_s, #deprecated
            payee: payee,
            payment_method: payment_method,
            transaction_type: transaction_type,
            amount: amount,
            amount_cents: amount_cents,
            transaction_date: transaction_date
          })
          @document.convert_base_64
          message = "document created succesfully"
          return render_response(true, message)
        end
# =begin
        if @user.save!

          # check words against keyterms
          words = description.split(' ').map!{ |w| w.downcase }
          trigger_terms = @user.get_accountant.keyterms.all
          if trigger_terms.any?
            trigger_terms.each do |trigger_term|
              if words.include? trigger_term.word
                # a term was found, trigger action
                action = trigger_term.triggers.first.action
                if action.verb
                  if action.verb == 'update'
                    new_label = action.term_new
                    @document.transaction_type = new_label
                    @document.save!
                  end
                end
              end
            end
          end

          message = "Document created succesfully"
          return render_response(true, message)
        else
          message = "Invalid user"
          return render_response(false, message)
        end
# =end
      end
      
      def submit
        #action = 'POST api/v1/uploads#create'

        guid = params[:guid] || ''
        description = params[:description] || ''
        
        if guid == ''
          puts "guid empty"
        end
        
        if params[:transaction_type] == 'mileage'
          trip_date = params[:trip_date] || nil
          trip_time = params[:trip_time] || nil
          distance = params[:distance] || nil
        else
          payee = params[:payee] || ''
          transaction_type = params[:transaction_type] || ''
          transaction_date = params[:transaction_date] || Time.now
          payment_method = params[:payment_method] || ''
          amount = params[:amount] || ''
        end
        
        @user = User.where({ guid: guid })
        if @user.any?
          @user = @user.first
        else
          message = "Invalid guid"
          puts "Invalid guid"
          return render_response(false, message)
        end

        image_content = ''
        if params[:image]
          if !params[:image].empty?
            image_content = params[:image].split().join('+')
          end
        end
        
        #for miles
        if params[:transaction_type] == 'mileage'
          @mile = @user.miles.create({
            base_64_image: image_content,
            description: description,
            distance: distance,
            trip_time: trip_time,
            trip_date: trip_date
          })
          @mile.convert_base_64
          message = "mileage created succesfully"
          return render_response(true, message)
        else
          amount_cents = amount.gsub(/\D/, '').to_i
          if /reimburs/i.match(description)
            reimbursable = true
          else
            reimbursable = false
          end
          
          @document = @user.documents.create({
            base_64_image: image_content,
            description: description,
            reimbursable: reimbursable,
            # metadata: metadata.to_s, #deprecated
            payee: payee,
            payment_method: payment_method,
            transaction_type: transaction_type,
            amount_cents: amount_cents,
            transaction_date: transaction_date
          })
          @document.convert_base_64
          message = "document created succesfully"
          return render_response(true, message)
        end
      end

      def render_response success, message
        output = {
          success: success,
          message: message
        }
        render json: output.as_json
      end

      private

      def parse_image_data(base64_image)
        filename = "upload-image-#{Time.now}"
        #in_content_type, encoding, string = base64_image.split(/[:;,]/)[1..3]

        @tempfile = Tempfile.new(filename)
        @tempfile.binmode
        @tempfile.write Base64.decode64(base64_image)
        @tempfile.rewind

        # for security we want the actual content type, not just what was passed in
        content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

        # we will also add the extension ourselves based on the above
        # if it's not gif/jpeg/png, it will fail the validation in the upload model
        
        #extension = content_type.match(/gif|jpeg|png/).to_s
        #filename += ".#{extension}" if extension
        filename += '.png'

        ActionDispatch::Http::UploadedFile.new({
          tempfile: @tempfile,
          content_type: content_type,
          filename: filename
        })
      end

    end
  end
end