# /human - skill cho Claude viết như người

Skill tiếng Việt giúp Claude viết (và viết lại) bài cho đọc như người viết. Nó sửa **cách bài được dựng lên** trước, rồi mới dọn câu chữ.

Dựa trên nghiên cứu [StoryScope](https://arxiv.org/abs/2604.03136) (Đại học Maryland và Google DeepMind): phân tích 61.608 truyện do người và AI viết, chỉ nhìn cách truyện được dựng (cốt truyện, thứ tự thời gian, nhân vật, chủ đề) mà vẫn tách được người với AI ở mức 93,2%. Xoá các dấu hiệu văn phong AI dễ thấy thì máy dò gần như không kém đi. Nên xoá dấu gạch ngang dài không làm bài của bạn giống người viết hơn.

## Cài đặt

**claude.ai (web hoặc app)**

1. Tải file [`human.skill`](human.skill) trong repo này (bấm vào file, rồi bấm nút tải về).
2. Vào **Settings** -> **Capabilities**, bật **Code execution and file creation**.
3. Vào **Customize** -> **Skills** -> **Add** -> **Upload a skill**, chọn file vừa tải.

**Claude Code**

```bash
git clone https://github.com/mindangg/human-skill.git
mkdir -p ~/.claude/skills && cp -r human-skill/human ~/.claude/skills/
```

## Cách dùng

Gõ `/human` trước câu lệnh:

- Viết mới: `/human viết caption TikTok về tháng đầu mình bán khoá học`
- Viết lại: `/human sửa lại bài này cho tự nhiên hơn` rồi dán bài vào
- Soi: `/human bài này có giống AI viết không?`

Skill không bịa số liệu hay chuyện bạn chưa kể. Thiếu chi tiết thì nó để tối đa ba chỗ trống trong ngoặc vuông cho bạn điền.

## Bên trong có gì

Chín nguyên tắc cấu trúc rút từ nghiên cứu (đừng nói ra bài học, gọi tên cảm xúc, nêu tên thật, nói với người đọc, đừng thắt nơ, cho bài đi lạc một chút, đảo thứ tự, đẩy căng thẳng lên đỉnh, chọn góc ít hiển nhiên), dấu vân tay riêng của ChatGPT, Gemini, DeepSeek, rồi mới tới lượt dọn chữ sáo. Xem đầy đủ ở [`human/SKILL.md`](human/SKILL.md).

## Giấy phép

MIT. Làm bởi Minh Đăng ([@mindang.com](https://www.tiktok.com/@mindang.com) trên TikTok).

Ý tưởng lấy cảm hứng từ video của Michael Ly ([@millee.md](https://www.instagram.com/millee.md/)). Nội dung skill viết lại bằng tiếng Việt, trực tiếp từ nghiên cứu [StoryScope](https://arxiv.org/abs/2604.03136).
