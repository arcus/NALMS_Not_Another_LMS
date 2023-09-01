## What happened

There were two (unrelated?) problems: 

1. **Participants not seeing their progress:** At the end of week 1 we got emails from learners letting us know that they tried to save their progress but when they checked again it hadn't been saved. For example, see email from G (first initial) 8/14.
2. **ASIs not being scheduled:** ASI's also weren't being properly scheduled -- people who filled out the form at least once were no longer scheduled to receive the next update Monday morning.

## What we did

- Contacted Lara, and she helped!
- Deleted all current ASIs. The links in them were badly formatted (we had `[survey-link:Progress on the aster pathway][new-instance]` and it should have been `[survey-link:aster_pathway:Progress on the aster pathway][new-instance]`).
- Created a test project
    * put fresh ASIs in there with corrected links and 8/14 start dates
    * also created alerts to replace the ASIs altogether
- Elizabeth created a new script to generate the progress alerts (taking the place of the ASIs).
- We ended up switching to alerts and abandoning the ASIs entirely as we couldn't get them to work

## REDCap's behavior, as far as we understand it

**Problem 1**

- When learners clicked the link in their ASI, it took them to the correct survey page (i.e. right pathway), but filled in with the values from instance 1 (or, possibly, the default values) rather than values from their last instance. Fields on pathway surveys include annotations like `@IF([current-instance]=1,@DEFAULT='0', @SETVALUE='[magnolia_reproducibility:value][last-instance]').`, which sets them to 0 when current-instance is 1 and whatever the value of last-instance is for that item otherwise. 
- REDCap did correctly save responses as a new instance, though. Participant G submitted progress updates 2023-08-09 13:28:58, 2023-08-10 17:49:55, and 2023-08-10 23:07:27 before emailing us, and those all saved as new instances in their record. 
- Crucially, REDCap did NOT overwrite instance 1 (that was one of Lara's hypotheses), even though it was showing values from instance 1 (or perhaps defaults).
- Using the corrected links in the new alerts results in the expected behavior: Participants see their most recent responses loaded in the survey.

**Problem 2**

- We thought at one point that REDCap was failing to schedule ASIs because it had a limit of 5 per record, but that's for reminders on an ASI not repeated ASIs for a repeating instrument. 
- Joy and Rose H did a lot of testing to try to get the ASIs to schedule as intended and encountered some very confusing behavior from REDCap. We never came up with a satisfactory explanation for why the ASIs weren't being scheduled. See Appendix for Joy's troubleshoooting notes. 
- Lara explained in a later meeting that repeating intrument ASIs are actually a relatively new feature and there may be unknown bugs in their behavior. 

**New Problem**

- When Elizabeth was creating and testing alerts to replace the ASIs, the preview was failing to correctly pipe in current status information for each module, in a super confusing way. Turns out the preview may be buggy; it's a much better idea to use the notificatin log, which shows scheduled notifications so you can see how they'll be rendered. 

## Summary

We still don't know exactly what went wrong, but the following things have become clear:

- The repeating instrument ASIs included links that were incorrectly formatted. The fact that these bad links worked as expected during testing in May was probably the result of us unknowingly taking advantage of a bug, which REDCap later "corrected" in a regular update (such as the update 2023-08-07, during week 1 of the program). It wasn't clear to anyone, even Lara, why our unorthodox links resulted in participants seeing what they did (the correct survey, but a problem with the default values displayed) rather than just failing to work at all. 
- The repeating instrument ASIs appear to have some bugs in their behavior even when set up correctly. We noted inconsistent behavior that we couldn't correct. The best way to test this would be to start a new (simpler) project from scratch, to build a reprex, but that's probably not a good use of our time at the moment. 
- We didn't lose data. It appears that participant responses continued to be correctly recorded throughout the whole debacle. 
- We need to build in more regular consultation with the REDCap team. They have important insight we lack, and just because something appears to be "working" doesn't mean we've built it well. 

Proposal going forward:

- Abandon ASIs for repeating instruments and stick to only alerts in NALMS. We've already done this.
- Test our project(s) on new versions of REDCap before updates go live, to hopefully discover unexpected breaking changes before they occur. Lara has added the dart email to the list of emails that get advance access to new versions of REDCap. 
- Build a habbit of regular consultation and checks with the CHOP REDCap team. They might have noticed things like our wonky links and had us correct them even when they were initially working. 
- Continue making use of scripts (e.g. bash) to generate REDCap files; eveyrthing was much faster to troubleshoot and update because that was all automated! We also knew for sure that things were created the same way across all 19 pathways because none of it was done by hand. That meant we could check/test a single pathway and know the others would work the same. 

## Appendix

Joy's email from 2023-08-14:

Hi all,
 
Update on ASIs – it’s a hot mess, we pivoted to Alerts and all the right people will be Alerted at 8:05 this morning.  But problems persist for the longer term.
 
Elizabeth, if you see this before 8:05 you can spot check my work but I am 95% sure it’s right.  401 alerts which is the same number of ppl who have pre-test done.
 
Remember how some ASIs lack checkboxes?  Those are repeating ASIs.  The best way to remove those is to change the conditions to that ASI such that it will always be false, and they’ll disappear.
 
Our first problem was that we were scheduling ASIs according to the ASI but they did not appear in the notification log (this is the video question).  This is because we set the number of sends to 1, and most people had already gotten their 1, so while from the ASI perspective these were valid to send, it is the notification system that realizes “whoops, everyone but these two latecomers already got one, so these won’t go out.”  I raised the number of sends to 2 and suddenly the number of notifications went way up (e.g. from 0 to 20 on the Aster instrument).
 
An aside question -- since these are new sends (repeats, not reminders) for a repeating instrument, is there truly a limit of 5?  The screen makes it seem like you can do UNLIMITED (e.g. weekly symptom checkers).  However, we saw that they did in fact get cut off.  This makes me wonder if we hit an unpublished limit or bug in REDCap.
 
Our second problem is why changing the repeat value did not fix the problem for everyone.  We expect 31 invitations for Aster, but only 20 were getting into the log.  A bit of background here is merited. All participants have an initial complete instance (generated by us, not by a survey completion) of their pathway (19 different forms like aster, azalea, begonia, and each participant has one and only one of these).  This is set up as repeating, because participant can and should log their progress using their respective flower forms.  But unfortunately, if a participant filled out and submitted an update, (a thing we want!) say, in a second (or third) instance of their flower form, they were NOT getting ASIs scheduled.  Only people who had not submitted an update were getting ASI scheduled (e.g. record 3 in the Aster pathway did get an SI scheduled, but record 50 in the Aster pathway did not). 
 
I tested the logic of the Aster survey against record 3 and record 50, and they evaluated differently.  Record 3, the conditions ([pathway]="aster" and [aster_complete][last-instance]<>"2" and [wave] = "2" and [stop_emails]="0" and [pretest_complete]="2") evaluated TRUE but in Record 50, they evaluated FALSE.  AHA!  We think we found the problem!  Could it be that [aster_complete][last-instance] is causing problems, similar to how our use of [new-instance] was causing problems with creating URLs?
 
When we changed the condition [aster_complete][last-instance]<>"2", to just [aster_complete]<>"2",  Record 50 started evaluating as TRUE.  Background is that aster_complete is a calculated field (not the default completeness field in REDCap, which in this case is actually aster_pathway_complete) which calculates whether each question has been answered with the answer “Done”, indicating that the participant is all complete and shouldn’t get more emails.  But in truth every instance of aster
_complete is 0 in both record 3 (which has one instance) and record 50 (which has 2).  Is [aster_complete]<>"2" always checking the most recent completion?  All completions?  Certainly [aster_complete][last-instance]<>"2" was not evaluating properly!
 
BUT BUT BUT… although record 50 now evaluates as TRUE, invitations are NOT being created for record 50!  We had hoped this weird conditions blocker, which seemed to account for the difference between the 20 invitations we saw and the 31 we expected to see, would fix the issue.  It does not, however.  This is the biggest problem – the ASI logic checker says “yep, this record should get one” and we know it’s not a “counting” issue like in our first problem, but the notification does not get scheduled.  This looks like a bug?  Or some weird thing with repeating instruments that we understand poorly.  But the info at https://ws.engr.illinois.edu/sitemanager/getfile.asp?id=3284 seems to indicate we did it right, I think. 
 
Our third problem is that even with the 20 Aster pathway folks that were in fact scheduled to get a notification, their first notification was scheduled to be seven days after the initial send indicated in the ASI setup.  Our setup was to start today, 8/14, with a repeat in 7 days.  But their first send (marked #2 in the notification log) was scheduled to be actually on 8/21.  I suspect this is because the notification log remembers that the “first send” (which happened in the older version of the ASIs with the bad URL links) already went out for these folks, so they’re not due for the “first” in this new, updated ASI… so it jumps to their second send.  This might be important to alert REDCap users of!  It might be that we have to activate and deactivate the survey or something to reset that this is a brand new ASI with new counting rules. 
 
Our solution, for now, is to blow away all ASI notifications and move to email notifications.  However, we are concerned with ASI performance / unpublished behavior / potential bugs.
 
Rose H, anything else I missed from our work sesh on Sunday?
 
Joy


Elizabeth's email from 2023-08-11:

Hi Rose H and everyone else!
 
Not quite _all_ problems are solved, but for the immediate time being, we are good? Everyone else please chime in if that is wrong.
 
As the title of this email might have alerted you, on Friday (like as I type this email) there were some problems… ☹. I’m putting a description of what happened here for documentation purposes and so you know what is up.
 
What happened:
A learner reported that their pathway progress survey was not updating. Upon investigating we learned
The links to surveys and urls in the ASIs need to have the instrument_name inside in order to generate the correct link in combination with the [new-instance] logic.
The surveys were correctly updating, users just couldn’t return to new instances of their surveys quite correctly.
ASIs can only send out 5 reminders.
People who filled out the form at least once were no longer scheduled to receive the next update Monday morning.
 
How we fixed it with lots of help from Lara ❤:
Deleted all current ASIs with the wrong links in them.
Regenerated new ASIs with
correct links in them (eg [survey-link:aster_pathway:Progress on the aster pathway][new-instance], we added this to the generating scripts)
new start date of 8/14 so that people don’t get an extra email
Uploaded these new ASIs (not yet as I write this email but will be completed before you see this).
 
Things we will need to do in the coming week(s):
Create alerts (rather than ASIs) for the future weeks after the 7th week since we can’t send more than 5 ASIs per survey. According to Lara, using the instrument name in an alert should work just the way it would from an ASI (I’m pretty sure not knowing this was why we used ASIs instead of alerts for this in the first place).
I think that is it?
 
It has been a fun Friday, hopefully your travels have been smooth!
 
-Elizabeth