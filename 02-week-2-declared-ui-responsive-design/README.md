4. PRAKTIKUM: Layout Sederhana (warm-up)
![alt text](screenshot/image1.png)
Experiment Warm-Up
1. ![alt text](screenshot/image2.png)
2. ![alt text](screenshot/image3.png)
3. ![alt text](screenshot/image4.png)

5. PRAKTIKUM: Dashboard Responsif
![alt text](screenshot/image5.png)
![alt text](screenshot/image6.png)
![alt text](screenshot/image7.png)
Experiment Layout
1. When i change it to 300 it will look like this
![alt text](screenshot/image8.png)
2. i changed the color theme like this 
"themeMode: isDark ? ThemeMode.dark : ThemeMode.system,"
so even though i change the mode in the apps, it still dark because my system is dark mode.
![alt text](screenshot/image9.png)
3. Iphone 14 Pro Max 
![alt text](screenshot/image10.png)
iPad pro
![alt text](screenshot/image11.png)
4. ![alt text](screenshot/image12.png)
to give context about the button.
![alt text](screenshot/image13.png)
to combine separate data to a complete content

6. ASSIGNMENT and AI design exploration

AI Prompt Challenge
1. Prompt: "Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya."
Answer:
![alt text](screenshot/image14.png)
Test: GridView
![alt text](screenshot/image21.png)
LayoutBuilder + Column
![alt text](screenshot/image22.png)

2. Prompt: "Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan perbaikannya."
Answer: 
![alt text](screenshot/image15.png)
![alt text](screenshot/image16.png)

3. Prompt: "Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"
Answer:
![alt text](screenshot/image17.png)
![alt text](screenshot/image18.png)
![alt text](screenshot/image19.png)
![alt text](screenshot/image20.png)

Refactoring Challenge
1. class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.value, super.key});
  final String title;
  final String value;}
  InfoCard(title: 'Assignments', value: '8'),
              InfoCard(title: 'Attendance', value: '92%'), 
              InfoCard(title: 'Portfolio', value: 'Ready'), 
              InfoCard(title: 'Current week', value: '02'), 
2. style: Theme.of(context).textTheme.headlineSmall,
3. const double kWideBreakpoint = 700;
final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1; 
4. 
![alt text](screenshot/image23.png)

Testing Dasar
flutter test
![alt text](screenshot/imag24.png)

Reflection
1. Imperative UI explains how to build or change the UI step by step. Declarative UI explains what the UI should look like based on its current state.
2. Expanded helps widgets use the available space in a Row or Column. It can cause errors when there is not enough or unlimited space available.
3. Breakpoints make the UI fit different screen sizes. Themes make the UI consistent and can support light and dark modes.
4. I tested the code to make sure it worked, compiled correctly, and the layout was responsive.