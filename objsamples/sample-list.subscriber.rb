require '../ET_Client.rb'
require 'securerandom'

begin
	stubObj = ET_Client.new(false, false)	
	
	# NOTE: These examples only work in accounts where the SubscriberKey functionality is not enabled
	#       SubscriberKey will need to be included in the props if that feature is enabled	
	
	NewListName = "RubySDKListSubscriber"
	SubscriberTestEmail = "RubySDKListSubscriber@bh.exacttarget.com"
	
	# Create List 
	p '>>> Create List'
	postList = ET_List.new 
	postList.authStub = stubObj
	postList.props = {"ListName" => NewListName, "Description" => "This list was created with the RubySDK", "Type" => "Private" }		
	postResponse = postList.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect	
	
	
	# Make sure the list created correctly before 
	if postResponse.status then 
		
		newListID = postResponse.results[0][:new_id]
	
		# Create Subscriber On List 
		p '>>> Create Subscriber On List'
		postSub = ET_Subscriber.new 
		postSub.authStub = stubObj
		postSub.props = {"EmailAddress" => SubscriberTestEmail, "Lists" =>[{"ID" => newListID}]}		
		postResponse = postSub.post
		p 'Post Status: ' + postResponse.status.to_s
		p 'Code: ' + postResponse.code.to_s
		p 'Message: ' + postResponse.message.to_s
		p 'Result Count: ' + postResponse.results.length.to_s
		p 'Results: ' + postResponse.results.inspect	
		
		if postResponse.status == false then 
			# If the subscriber already exists in the account then we need to do an update.
			# Update Subscriber On List 
			if postResponse.results[0][:error_code] == "12014" then 	
				# Update Subscriber to add to List
				p '>>> Update Subscriber to add to List'
				patchSub = ET_Subscriber.new 
				patchSub.authStub = stubObj
				patchSub.props = {"EmailAddress" => SubscriberTestEmail, "Lists" =>[{"ID" => newListID}]}	
				patchResponse = patchSub.patch
				p 'Patch Status: ' + patchResponse.status.to_s
				p 'Code: ' + patchResponse.code.to_s
				p 'Message: ' + patchResponse.message.to_s
				p 'Result Count: ' + patchResponse.results.length.to_s
				p 'Results: ' + patchResponse.results.inspect
			end 		
		end 
		
		# Retrieve all Subscribers on the List
		p '>>> Retrieve all Subscribers on the List'
		getListSubs = ET_List::Subscriber.new
		getListSubs.authStub = stubObj	
		getListSubs.props = ["ObjectID","SubscriberKey","CreatedDate","Client.ID","Client.PartnerClientKey","ListID","Status"]
		getListSubs.filter = {'Property' => 'ListID','SimpleOperator' => 'equals','Value' => newListID}
		getResponse = getListSubs.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s	
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s		
		
		# Delete List
		p '>>> Delete List'
		deleteSub = ET_List.new()
		deleteSub.authStub = stubObj	
		deleteSub.props = {"ID" => newListID}
		deleteResponse = deleteSub.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s	
		p 'Results Length: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.to_s		
	end
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end
