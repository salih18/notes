Here’s a simplified and less technical version of your question for Microsoft Azure support. It still covers the key points—Defender for Storage options, costs, and your solution for uploading files to a static site, scanning them, and disabling Defender—while avoiding deep technical details like API specifics or script snippets. This makes it more accessible while ensuring Microsoft understands your needs.

---

**Subject:** Questions About Defender for Storage Options, Costs, and On-Demand Scanning for Static Site

**Dear Microsoft Azure Support Team,**

I need some help understanding Microsoft Defender for Storage for our Azure storage accounts, especially how it works with a static site we host. Right now, Defender is turned on at the subscription level, and it’s costing us 5 euros per storage account per month with only “Activity Monitoring” active. The other two features—“Sensitive Data Threat Detection” and “On-Upload Malware Scanning”—are off. We want to upload files to our static site’s `$web` folder, scan them for malware, and then turn off Defender to keep costs low. Here are my questions:

1. **What Each Option Does:**
   - **Activity Monitoring**: I think this watches for suspicious actions on our storage account. Does it check files for malware, or just track things like who’s accessing them?
   - **Sensitive Data Threat Detection**: What would this do for our static site if we turned it on? Does it protect files differently?
   - **On-Upload Malware Scanning**: This sounds like what we need to scan our files for malware when we upload them. Does it work for all file types in our `$web` folder, like HTML and images?

2. **Costs:**
   - We’re paying 5 euros per storage account per month now with just Activity Monitoring. Why is it less than the $10 I’ve seen online? Is this a special rate for Europe or something else?
   - If we turn on Malware Scanning, how much extra will it cost? For example, if we upload 1 GB of files, what’s the total cost for a quick 10-minute scan?
   - Does turning on Sensitive Data Threat Detection add more to the bill, or is it part of the 5 euros?

3. **Our Plan to Upload, Scan, and Turn Off:**
   - We’re trying a solution where we:
     1. Turn on Defender with malware scanning for one storage account.
     2. Upload our static site files to `$web` (it’s empty at the start).
     3. Wait a bit to let it scan the files.
     4. Check for any alerts about malware.
     5. Turn off Defender for that account.
   - Will this work with Defender already on at the subscription level? Can we really stop the 5 euros cost for that storage account afterward, or do we need to do something else to avoid it?
   - How long should we wait for scanning to finish if we upload 1 GB of files? Is 10 minutes enough?
   - If we do this daily with 1 GB, what’s the cost each time?

4. **Other Ideas:**
   - Is there a simpler way to scan files for malware just when we upload them, without keeping Defender on all the time? We don’t want to pay 5 euros per month for this storage account.
   - Should we switch to a different Defender plan if ours is old or limited?

**Extra Info:**
- We upload between 20 MB and 1 GB of files daily for our static site.
- We’re in Europe and want to keep each upload-and-scan under 0.50 euros.

Could you explain how these options work for us, what they’ll cost, and if our plan makes sense? Any tips to save money would be great. Thanks so much!

**Best regards,**  
[Your Name]  
[Your Contact Info]  
[Your Subscription ID, if applicable]

---

### Why This Works
- **Simple Language**: Avoids technical jargon (e.g., APIs, JSON) while keeping the focus on what you need.
- **Structured**: Uses numbered sections for clarity and easy responses.
- **Focused**: Covers the three Defender options, costs, and your upload-scan-disable solution without overwhelming detail.
- **Action-Oriented**: Asks for practical advice and cost estimates tailored to your static site.

You can submit this through the Azure portal’s **Help + Support** or a forum. Want to tweak it more or add something specific? Let me know!
