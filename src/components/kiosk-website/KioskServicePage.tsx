import './KioskServicePage.css';
import MapSection from './MapSection';
import { useState } from 'react';

export default function KioskServicePage() {
  const [expandedItems, setExpandedItems] = useState<number[]>([]);

  const instructions = [
    {
      id: 1,
      title: "التأكد من التسجيل الإلكتروني و دفع مخالفات المركبة",
      description: (
        <>
          يتم التحقق من حالة التسجيل الإلكتروني للمركبة عن طريق الموقع الإلكتروني{' '}
          <a
            href="https://reg.traffic.gov.eg"
            target="_blank"
            rel="noopener noreferrer"
            className="instruction-link"
            onClick={(e) => e.stopPropagation()}
          >
            هذا
          </a>{' '}
          او عن طريق مسح رمز ال QR من خلال الماكينة مع سداد المخالفات المرورية المستحقة من خلال الموقع الإلكتروني{' '}
          <a
            href="https://ppo.gov.eg"
            target="_blank"
            rel="noopener noreferrer"
            className="instruction-link"
            onClick={(e) => e.stopPropagation()}
          >
            ppo.gov.eg
          </a>{' '}
          إن وجدت لضمان استكمال إجراءات التجديد بسهولة ودون معوقات.
        </>
      )
    },
    {
      id: 2,
      title: "فحـص المركبة فـي وحدات الفحص إن وجد ",
      description: "يتم إجراء الفحص الفني للمركبة في وحدات الفحص المعتمدة عند الحاجة للتأكد من مطابقتها لمعايير السلامة والصلاحية قبل إتمام إجراءات التجديد"
    },
    {
      id: 3,
      title: "التوجه لأقرب ماكينة ",
      description: "يمكن للمستخدم تحديد موقع أقرب ماكينة تجديد ذاتي من خلال الموقع الإلكتروني والتوجه إليها لإتمام إجراءات تجديد رخصة تسيير المركبة بسهولة وسرعة."
    },
    {
      id: 4,
      title: "متابعة الخطوات من خلال ماكينة التجديد الذاتي ",
      description: `إدخل الرقم القومي و رقم المحمول 
إدخـل رمـز التحقق OTP
إختر المركبة المراد التعامل عليها 
إختر من الخدمات المتاحة ( تجديد - بدل فاقد - بدل تالف ) 
الموافقة علي الشروط و الأحكام
اختر مدة الترخيص ( سنة - 3 سنوات ) `
    },
    {
      id: 5,
      title: "متابعة عملية الدفع",
      description: "يرجى الانتظار حتى تظهر قيمة رسوم التجديد على ماكينة الدفع الإلكتروني، ثم إتمام عملية السداد باستخدام بطاقة الدفع  لإكمال إجراءات التجديد بنجاح"
    },
    {
      id: 6,
      title: "إستلم الرخصة",
      description: "يرجى الانتظار حتى تقوم الماكينة بطباعة الرخصة الجديدة"
    },
  ];

  const toggleItem = (id: number) => {
    setExpandedItems(prev =>
      prev.includes(id) ? [] : [id]
    );
  };

  return (
    <div className="kiosk-page" dir="rtl">


      {/* Hero Section */}
      <section className="hero-section">
        <img src="banner.png" alt="Hero" className="banner-desktop" style={{
          width: "100%"
        }} />
        <img src="banner2.png" alt="Hero" className="banner-mobile" style={{
          width: "100%"
        }} />
      </section>

      {/* About Section */}
      <section className="about-section">
        <h2>عـــن الـخــدمــة</h2>
        <div className="about-content">
          <ul>
            <li>في إطار جهود الدولة للتحول الرقمي وتطوير الخدمات الحكومية، أطلقت وزارة الداخلية ، خدمة الإصدار الذاتي لرخص تسيير المركبات، وذلك من خلال ماكينات التجديد الذاتي المنتشرة في عدد من المواقع الحيوية.</li>
            <li>تهدف هذه الخدمة إلى تمكين المواطنين من تجديد رخص تسيير مركباتهم بصورة سريعة وآمنة، دون الحاجة إلى الانتظار أو التوجه إلى وحدات التراخيص، حيث تتيح ماكينات التجديد الذاتي إمكانية إتمام إجراءات التجديد خلال مدة لا تتجاوز دقيقتان.</li>
            <li>وتعتمد الخدمة على أحدث الأنظمة التقنية لضمان الدقة وسرعة الأداء، مع توفير تجربة استخدام سهلة ومبسطة، بما يسهم في توفير الوقت والجهد على المواطنين، وتحسين جودة الخدمات المقدمة، ودعم توجه الدولة نحو التحول الرقمي وتقديم خدمات حكومية ذكية ومتكاملة.</li>
          </ul>
        </div>
        <div className="about-button-container">
          <a href="https://reg.traffic.gov.eg" className="about-action-button" target="_blank" rel="noopener noreferrer">
            تسجيل دخول / إنشاء حساب
          </a>
        </div>
      </section>

      {/* Instructions Section */}
      <section className="instructions-section">
        <h2>إرشــادات عــامــة</h2>
        <div className="instructions-layout">
          <div className="instruction-list">
            {instructions.map((instruction) => (
              <div
                key={instruction.id}
                className={`instruction-card ${expandedItems.includes(instruction.id) ? 'expanded' : ''}`}
                onClick={() => toggleItem(instruction.id)}
              >
                <div className="instruction-header">
                  <div className="instruction-title">
                    <img src="checkmark.svg" alt="checkmark" className="checkmark" />
                    <span>{instruction.title}</span>
                  </div>
                  <button
                    className="toggle-btn"
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleItem(instruction.id);
                    }}
                  >
                    {expandedItems.includes(instruction.id) ? 'إغلاق' : 'عرض المزيد'}
                  </button>
                </div>
                {expandedItems.includes(instruction.id) && (
                  <div className="instruction-content">
                    <p>{instruction.description}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Locations Section */}
      <section className="locations-section">
        <h2>المــاكينــات الــمـتـاحـة</h2>
        <MapSection />
      </section>
      {/* Floating Action Button */}
      <a
        href="https://reg.traffic.gov.eg"
        target="_blank"
        rel="noopener noreferrer"
        className="fab"
      >
        تسجيل
      </a>
    </div>
  );
}
