/// FindFood's Terms of Service and Privacy Policy.
///
/// Written for Ghana (Data Protection Act, 2012 (Act 843); Electronic
/// Transactions Act, 2008 (Act 772); Public Health Act, 2012 (Act 851); Road
/// Traffic Act, 2004 (Act 683)). Have a Ghanaian lawyer review them before
/// launch, and update [legalUpdated] whenever the wording changes.
///
/// Light markup in paragraphs: "- " starts a bullet, "> " a highlighted note,
/// and **text** is bold.
library;

const supportEmail = 'support@findfood.app';
const legalUpdated = '14 October 2026';

class LegalSection {
  final String id;
  final String title;
  final List<String> paragraphs;
  const LegalSection(this.id, this.title, this.paragraphs);
}

class LegalDocument {
  final String title;
  final String intro;
  final List<String> summary;
  final List<LegalSection> sections;
  const LegalDocument({
    required this.title,
    required this.intro,
    required this.summary,
    required this.sections,
  });
}

const termsOfService = LegalDocument(
  title: 'Terms of Service',
  intro: 'These terms are the agreement between you and FindFood when you order, '
      'sell or deliver food through the FindFood app or website. Please read them: '
      'by creating an account or placing an order, you accept them.',
  summary: [
    'FindFood connects you with restaurants and riders. Restaurants make the food; riders deliver it.',
    'You pay the price shown at checkout, in Ghana cedis, through Paystack (card or Mobile Money).',
    "Only give your 4-digit delivery code to the rider once you're holding your food. Giving it confirms you received the order.",
    'Something wrong? Report it within 48 hours with a photo, and we\'ll put it right if the problem is real.',
    'False claims, abuse and fraud lead to suspension. Everyone here is trying to make an honest living.',
  ],
  sections: [
    LegalSection('about', 'About FindFood and these terms', [
      'FindFood is an online marketplace operated in Ghana. It lets **customers** order food from '
          '**restaurant partners**, and lets independent **riders** deliver it.',
      'FindFood does not cook food and is not a restaurant. Each restaurant is responsible for the food it '
          'sells, and each rider is responsible for the way they deliver it. FindFood runs the platform, '
          'takes payments on the restaurant\'s behalf, and steps in when something goes wrong.',
      'These terms apply alongside our Privacy Policy. Restaurant partners and riders also agree to the '
          'sections written for them below.',
    ]),
    LegalSection('account', 'Your account', [
      '- You must be at least 18 years old to hold an account.',
      '- Give accurate details, including a name and contact details we can reach you on, and keep them up to date.',
      '- One person, one account. Keep your password private; you are responsible for activity on your account.',
      '- Tell us straight away at $supportEmail if you think someone else is using your account.',
      'You can close your account at any time from Settings or by contacting support. Orders already placed '
          'still need to be completed or cancelled first.',
    ]),
    LegalSection('ordering', 'How ordering works', [
      'When you place an order, you make an offer to buy food from that restaurant. The order is confirmed once '
          'your payment succeeds and the restaurant accepts it. A restaurant may decline an order, for example '
          'if an item has run out; if it does, you get a full refund.',
      'Menus, photos, prices and descriptions are provided by restaurants. They try to keep them accurate, but '
          'portion sizes and presentation can vary a little from the photos.',
      '> **Allergies and dietary needs:** FindFood cannot guarantee that any food is free from allergens. '
          'If you have an allergy, message the restaurant from your order before it is prepared and ask. '
          'If you are not sure, do not order.',
    ]),
    LegalSection('prices', 'Prices, fees and payment', [
      '- Prices are in Ghana cedis (GH₵) and include any taxes the restaurant must charge.',
      '- Checkout shows the full amount before you pay: food, delivery fee and any service fee. You pay that '
          'amount and nothing more.',
      '- Payments are processed by Paystack, a licensed payment provider. You can pay by card or Mobile Money. '
          'FindFood never sees or stores your full card number or Mobile Money PIN.',
      '- An order that is not paid within a short time is cancelled automatically.',
      '- Promotions and discounts have their own conditions, shown with the offer. They cannot be exchanged '
          'for cash.',
    ]),
    LegalSection('delivery', 'Delivery, pickup and handover codes', [
      'Estimated times are estimates. Traffic, weather and busy kitchens can cause delays; you can follow your '
          'order live and chat with the restaurant or your rider.',
      'Every delivery uses two codes so food goes to the right people:',
      '- **Pickup code:** the rider shows it to the restaurant, which enters it before handing over the food.',
      '- **Delivery code:** you give your 4-digit code to the rider when you receive your food. The rider '
          'enters it to complete the delivery.',
      '> **Never share your delivery code before you are holding your order.** Giving the code confirms you '
          'received it, and we rely on it when we review any later complaint.',
      'For pickup orders, collect your food at the restaurant at the time shown. If you do not collect it, the '
          'restaurant has still prepared it, so it may not be refunded.',
      'Please make sure the address and pin you give are correct and that you can be reached. If the rider '
          'cannot find or reach you after reasonable attempts, the order may be treated as delivered.',
    ]),
    LegalSection('cancellations', 'Cancelling an order', [
      '- **Before the restaurant starts preparing it:** you can cancel from your order and get a full refund.',
      '- **After preparation has started:** the order can no longer be cancelled, because the food is being made for you.',
      '- **If the restaurant declines or cancels:** you get a full refund automatically.',
      'Refunds go back to the card or Mobile Money wallet you paid with. Card refunds can take 5 to 10 working '
          'days to appear; Mobile Money is usually faster. Timing depends on your bank or network.',
    ]),
    LegalSection('problems', 'Problems with an order and refunds', [
      'If something is wrong with your order, report it from the order screen:',
      '- **Wrong item, missing item, or damaged or spilled food:** within 48 hours of delivery, with a photo of '
          'what you received (the food and the packaging).',
      '- **Order never arrived:** once it has been on the way for more than an hour.',
      'We review every report against the restaurant\'s and rider\'s accounts, the handover codes, the chat and '
          'the photo. We may then refund the whole order, refund part of it (for example one missing item), or '
          'decline the report and tell you why. We aim to reply within 48 hours.',
      'You can report up to 3 orders in any 30 days in the app. After that, please contact support so we can '
          'look into what is going wrong with you directly.',
      'Refunds are made to your original payment method. FindFood does not give cash refunds.',
    ]),
    LegalSection('fair-use', 'Fair use, fraud and safety', [
      'FindFood works because customers, restaurants and riders can trust each other. You must not:',
      '- make false or exaggerated reports, or claim an order did not arrive when it did;',
      '- open card or Mobile Money disputes for orders you received, instead of reporting them to us;',
      '- use several accounts, someone else\'s payment details, or tricks to get promotions more than once;',
      '- share, guess or misuse pickup or delivery codes;',
      '- threaten, harass, insult or discriminate against anyone, in person or in chat;',
      '- interfere with the app, scrape it, or try to get into accounts or systems that are not yours.',
      'If we reasonably believe an account is being misused, we may decline refunds, cancel orders, limit '
          'features, recover money paid out wrongly, suspend or close the account, and report suspected crimes '
          'to the Ghana Police Service. Where possible we will tell you why and give you a chance to respond.',
    ]),
    LegalSection('reviews', 'Ratings and reviews', [
      'Only customers who received an order can rate it, so every review comes from a real order. Reviews must '
          'be honest and about the order. We may remove reviews that are abusive, contain personal information, '
          'are about something unrelated, or are part of a campaign for or against a restaurant.',
      'Restaurants may not offer anything in return for a review, or pressure customers to change one.',
    ]),
    LegalSection('chat', 'Chat and communication', [
      'Chat lets you talk privately with the restaurant or rider about your order. Keep it about the order and '
          'keep it respectful. When a problem is reported, FindFood staff may read the chats for that order to '
          'resolve it and to keep people safe.',
      'We send service messages, such as order updates, by email and notifications. You can turn off push '
          'notifications at any time; important account emails will still be sent.',
    ]),
    LegalSection('restaurants', 'For restaurant partners', [
      'If you sell on FindFood, you also agree that you will:',
      '- hold the licences and permits your business needs, including any Food and Drugs Authority (FDA) and '
          'local assembly requirements, and follow food hygiene and safety rules under Ghanaian law;',
      '- keep your menu, prices, photos, allergen information and opening hours accurate, and pause the '
          'kitchen when you cannot take orders;',
      '- prepare orders as described, pack them securely and seal them where you can;',
      '- hand a delivery order only to the rider who gives the correct pickup code;',
      '- accept or decline new orders promptly, and not cancel orders you have accepted except for genuine reasons;',
      '- treat riders and customers with respect, and not contact customers outside FindFood for marketing '
          'without their consent.',
      'FindFood collects payment for your orders and pays you the order value less the commission and fees '
          'agreed when you joined, which you can see in your Earnings. If a refund is given because of your '
          'mistake (for example a wrong or missing item), the refunded amount may be deducted from your payout. '
          'Repeated complaints, cancellations or safety concerns can lead to suspension.',
    ]),
    LegalSection('riders', 'For riders', [
      'If you deliver with FindFood, you also agree that you will:',
      '- hold a valid driving licence for your vehicle, keep it roadworthy and registered with the DVLA, carry '
          'any insurance the law requires, and follow the Road Traffic Act, including wearing a helmet on a motorbike;',
      '- only collect an order with your pickup code, and only complete a delivery with the customer\'s '
          'delivery code. Never complete a delivery without handing over the food;',
      '- never open, tamper with or eat from any order, and keep food in a clean, closed delivery bag;',
      '- release a job you cannot do before you collect it (you can release up to 2 a day) rather than leaving '
          'it waiting. Once you have collected food, you must deliver it;',
      '- be polite and safe, and contact FindFood support if anything goes wrong on a delivery.',
      'Riders are independent and choose when to go online. Your earnings for each delivery are shown in the '
          'app. FindFood may stop offering jobs to riders whose deliveries are repeatedly late, overdue or '
          'reported, and will hold back earnings for orders that were not delivered.',
    ]),
    LegalSection('content', 'Our content and yours', [
      'The FindFood name, logo, app and website belong to FindFood. You may use them only to use the service.',
      'When you post content (reviews, photos, menu items, chat messages), you keep ownership of it but give '
          'FindFood permission to store, display and use it to run and promote the service. Only post content '
          'you have the right to share.',
    ]),
    LegalSection('availability', 'Availability and changes to the service', [
      'We work hard to keep FindFood running, but it may sometimes be unavailable, for example during '
          'maintenance or outages with our providers. Restaurants and delivery areas can change. We may add, '
          'change or remove features to improve the service.',
    ]),
    LegalSection('liability', 'Our responsibility to you', [
      'Nothing in these terms takes away rights you have under Ghanaian law that cannot be excluded.',
      'Subject to that, FindFood is responsible for running the platform with reasonable care and skill. '
          'Restaurants are responsible for their food and riders for their deliveries. FindFood is not liable '
          'for losses that were not foreseeable, for business losses, or for problems caused by things outside '
          'our reasonable control. For any one order, our total liability to a customer is limited to the amount '
          'paid for that order.',
    ]),
    LegalSection('suspension', 'Suspending or closing accounts', [
      'We may suspend or close an account that breaks these terms, puts others at risk, or is used for fraud. '
          'Serious cases may be suspended immediately. You can contact $supportEmail if you believe a decision '
          'was wrong, and we will review it.',
    ]),
    LegalSection('changes', 'Changes to these terms', [
      'We may update these terms as FindFood grows or the law changes. If a change matters, we will tell you '
          'in the app or by email before it takes effect. Continuing to use FindFood afterwards means you accept '
          'the updated terms.',
    ]),
    LegalSection('law', 'Law and disputes', [
      'These terms are governed by the laws of the Republic of Ghana. If you have a complaint, contact us first '
          'and we will try to resolve it quickly. If we cannot agree, either side may refer the dispute to '
          'mediation under the Alternative Dispute Resolution Act, 2010 (Act 798), or to the courts of Ghana.',
    ]),
    LegalSection('contact', 'Contact us', [
      'Questions about these terms? Email $supportEmail or use Help & support in the app.',
    ]),
  ],
);

const privacyPolicy = LegalDocument(
  title: 'Privacy Policy',
  intro: 'This policy explains what personal data FindFood collects, why, who we share it with and the '
      'rights you have. We follow the Data Protection Act, 2012 (Act 843) of Ghana.',
  summary: [
    'We collect what we need to take, deliver and support your orders, and nothing to sell. We never sell your data.',
    'Restaurants and riders only see what they need for your order, such as your name and delivery location.',
    'Card and Mobile Money details are handled by Paystack. We never see your full card number or PIN.',
    'Location is only used for your delivery pin, and only when you choose to share it.',
    'You can see, correct or delete your data. Email $supportEmail.',
  ],
  sections: [
    LegalSection('who', 'Who we are', [
      'FindFood ("we", "us") runs the FindFood app and website in Ghana and decides how your personal data is '
          'used, which makes us the data controller under the Data Protection Act, 2012 (Act 843). You can '
          'reach us at $supportEmail.',
    ]),
    LegalSection('collect', 'What we collect', [
      '- **Account details:** your name, email address, phone number if you give it, your role (customer, '
          'restaurant or rider) and your password, which is stored only as a secure hash. If you sign in with '
          'Google, we receive your name, email address and profile picture from Google.',
      '- **Orders:** what you ordered, from where, prices, delivery address and map pin, delivery notes, '
          'order status and times, and the handover codes.',
      '- **Payments:** the payment reference, amount, method type and status. Card and Mobile Money details '
          'are collected by Paystack, not by us.',
      '- **Location:** the delivery location you choose. If you allow it, the app reads your device\'s '
          'location once to place your pin. We do not track anyone\'s location in the background.',
      '- **Messages and reports:** chats about an order, ratings and reviews, problem reports and the photos '
          'you attach.',
      '- **Restaurant and rider details:** business name, address, opening hours, menu and photos for '
          'restaurants; vehicle and payout details for riders.',
      '- **Device and usage:** your IP address, browser or device type, the pages you use, notification '
          'settings, and error reports when the app crashes, so we can fix it.',
    ]),
    LegalSection('use', 'How we use it', [
      '- to create and secure your account and sign you in;',
      '- to take, prepare, deliver and track orders, and to let you chat about them;',
      '- to take payments and make refunds;',
      '- to send order updates, receipts and account messages by email and notifications;',
      '- to prevent fraud and abuse, for example checking reports against handover codes and past reports;',
      '- to answer support requests and resolve complaints;',
      '- to keep the service working, fix errors and improve it;',
      '- to meet our legal duties, such as keeping tax and accounting records.',
      'We only send marketing messages if you agree to receive them, and you can stop them at any time.',
    ]),
    LegalSection('basis', 'Why we are allowed to use it', [
      'We use your data because it is needed to provide the service you asked for (our agreement with you), '
          'because we have a legitimate interest in keeping FindFood safe and working well, because the law '
          'requires it, or because you have consented, for example to push notifications or sharing your location. '
          'You can withdraw consent at any time in your device or browser settings.',
    ]),
    LegalSection('share', 'Who we share it with', [
      'We never sell your personal data. We share it only as follows:',
      '- **The restaurant** sees your name, your order and your notes.',
      '- **Your rider** sees your name, delivery location and notes, and can chat with you through the app.',
      '- **Customers** see a restaurant\'s details and their rider\'s name and the order\'s progress.',
      '- **Service providers** who work for us under contract and only use the data to provide their service: '
          'Paystack (payments), Google (sign-in), Brevo (email), Cloudinary (photo storage), and our hosting and '
          'database providers (Render, Vercel and Neon).',
      '- **Authorities**, where the law requires it or to protect someone\'s safety, for example the Ghana '
          'Police Service when investigating a crime.',
      '- **A buyer or investor**, if FindFood is ever reorganised or sold, under the same protections.',
    ]),
    LegalSection('transfers', 'Data stored outside Ghana', [
      'Some of our providers store data on servers outside Ghana, for example in Europe or the United States. '
          'When that happens we choose providers with strong security and contractual protections for your '
          'data, as Act 843 requires.',
    ]),
    LegalSection('retention', 'How long we keep it', [
      '- **Your account:** while it is open. When you close it, we delete or anonymise your personal data within '
          '30 days, except what we must keep below.',
      '- **Orders and payments:** for as long as Ghanaian tax and accounting laws require (generally 6 years).',
      '- **Chats, problem reports and their photos:** up to 12 months after the order, or longer if needed for an '
          'open complaint or a legal claim.',
      '- **Error reports:** up to 90 days.',
    ]),
    LegalSection('security', 'Keeping it safe', [
      'Passwords are stored as secure hashes. All traffic is encrypted with HTTPS. Access to personal data is '
          'limited to people who need it to do their job, and each order uses one-time handover codes. No system '
          'is perfectly secure, so please use a strong password and keep it private. If a breach affects you, we '
          'will tell you and the Data Protection Commission as the law requires.',
    ]),
    LegalSection('rights', 'Your rights', [
      'Under the Data Protection Act, 2012 (Act 843) you can:',
      '- ask for a copy of the personal data we hold about you;',
      '- ask us to correct data that is wrong or incomplete;',
      '- ask us to delete your data, unless we must keep it by law;',
      '- object to us using your data, or ask us to stop direct marketing;',
      '- withdraw consent you have given, such as for notifications or location.',
      'Email $supportEmail and we will reply within 21 days. If you are not happy with our answer, you can '
          'complain to the Data Protection Commission of Ghana.',
    ]),
    LegalSection('children', 'Children', [
      'FindFood is not meant for anyone under 18, and we do not knowingly collect children\'s data. If you think '
          'a child has given us their data, contact us and we will delete it.',
    ]),
    LegalSection('cookies', 'Cookies, storage and notifications', [
      'The website uses your browser\'s storage to keep you signed in, remember your basket and settings, and work '
          'faster. We do not use advertising cookies or sell browsing data.',
      'If you allow notifications, we store a notification address for your device so we can send order updates. '
          'You can turn them off in the app or in your browser or phone settings at any time.',
    ]),
    LegalSection('changes', 'Changes to this policy', [
      'We will update this policy when the way we use data changes, and tell you in the app or by email if the '
          'change matters. The date at the top shows when it last changed.',
    ]),
    LegalSection('contact', 'Contact us', [
      'For privacy questions or requests, email $supportEmail.',
    ]),
  ],
);
